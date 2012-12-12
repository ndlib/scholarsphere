class LowercaseLowerLabelName < ActiveRecord::Migration
  def change
    rename_column :subject_local_authority_entries, :lowerLabel, :lower_label
  end
end
