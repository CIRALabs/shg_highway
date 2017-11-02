# -*- ruby -*-

namespace :highway do

  desc "Maintain inventory of devices to buy, INVENTORY=count"
  task :inventory => :environment do

    inv_count = ENV['INVENTORY'] || 5

    # where is the inventory stored?
    inv_dir = SystemVariable.string(:inventory_dir)
    unless inv_dir
      # set a sane default
      inv_dir = Rails.root.join('db/inventory')
      SystemVariable.setvalue(:inventory_dir, inv_dir)
    end

    # make sure the directory exists.
    FileUtils.mkdir_p(inv_dir)

    sold_dir = File.join(inv_dir, "sold")
    FileUtils.mkdir_p(sold_dir)

    # now count how many devices exist which have no owner.
    if Device.unowned.count < inv_count

      devices_needed = inv_count - Device.unowned.count
      puts "creating #{devices_needed} devices to refill inventory"
      (1..devices_needed).each { |cnt|

        # need to create some new devices.... make up some new MAC addresses.
        next_mac = SystemVariable.nextval(:current_mac)

        base_mac = SystemVariable.string(:base_mac) || "00-d0-e5-f2-10-00"
        # turn it into a number.
        base_mac_number = base_mac.gsub(/[:-]/,'').to_i(16)
        mac_number = next_mac + base_mac_number

        mac_addr = sprintf("%02x-%02x-%02x-%02x-%02x-%02x",
                           (mac_number >> 40) & 0xff,
                           (mac_number >> 32) & 0xff,
                           (mac_number >> 24) & 0xff,
                           (mac_number >> 16) & 0xff,
                           (mac_number >>  8) & 0xff,
                           (mac_number) & 0xff)

        puts "Creating device #{cnt} with mac #{mac_addr}"

        newdev = Device.create_by_number(mac_addr)
        tdir = HighwayKeys.ca.devicedir
        newdev.gen_and_store_key(tdir)

        # now zip up the key.
        zipfile = File.join(inv_dir, newdev.zipfilename)
        cmd = "cd #{tdir} && zip -r #{zipfile} #{newdev.device_dir(tdir)}"
        puts "Running: #{cmd}"
        system("cd #{tdir} && zip -r #{zipfile} #{newdev.sanitized_eui64}")
      }

    end

    # now look for devices which are owned by still seem to be available
    # for download.
    Device.owned.each { |dev|
      zipfile = File.join(inv_dir, dev.zipfilename)
      if File.exists?(zipfile)
        sold_zipfile = File.join(sold_dir, dev.zipfilename)

        puts "Marking #{zipfile} as sold"
        File.rename(zipfile, sold_zipfile)
      end
    }

  end

end