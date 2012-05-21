class CreateUserToos < ActiveRecord::Migration
  def change
    create_table :user_toos do |t|

      t.column :login, :string, :null=>false, :default=>''
      t.column :email, :string, :default => ''
      t.timestamps
    end
  end
end
