
require 'statsd'

METRICS = Statsd.new('libvirt1.library.nd.edu', 8125)

if Rails.env.dlvecnet?
  METRICS.namespace = 'vecnet'
else
  Statsd.logger = Rails.logger
end

#Rack stats, courtesy of technoweenie
Rails.application.middleware.insert_before ActionDispatch::Static, RackStatsD::ProcessUtilization, 'lib-1643', '1', :stats => METRICS

SELECT_DELETE = / FROM `(\w+)`/
INSERT = /^INSERT INTO `(\w+)`/
UPDATE = /^UPDATE `(\w+)`/

ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
  case payload[:sql]
  when /^SELECT/
    payload[:sql] =~ SELECT_DELETE
    METRICS.increment('sql.select')
    METRICS.timing("sql.#{$1}.select.query_time", (finish - start) * 1000, 1)
  when /^DELETE/
    payload[:sql] =~ SELECT_DELETE
    METRICS.increment('sql.delete')
    METRICS.timing("sql.#{$1}.delete.query_time", (finish - start) * 1000, 1)
  when /^INSERT/
    payload[:sql] =~ INSERT
    METRICS.increment('sql.insert')
    METRICS.timing("sql.#{$1}.insert.query_time", (finish - start) * 1000, 1)
  when /^UPDATE/
    payload[:sql] =~ UPDATE
    METRICS.increment('sql.update')
    METRICS.timing("sql.#{$1}.update.query_time", (finish - start) * 1000, 1)
  end
end

class Redis::Client
# HACK: This overrides the normal Redis gem debug logging.
  def logging(commands, &block)
    METRICS.time("redis.#{commands.first.first}.time", &block)
  end
end
