class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.text :name
      t.text :fqdn
      t.text :dn
      t.text :certificate
      t.text :last_ip

      t.timestamps null: false
    end
  end
end
