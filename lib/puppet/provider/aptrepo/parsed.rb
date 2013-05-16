require 'puppet/provider/parsedfile'

Puppet::Type.type(:aptrepo).provide(:parsed,
    :parent => Puppet::Provider::ParsedFile,
    :filetype => :flat,
    :default_target => "/etc/apt/sources.list"
) do
    desc "Parse and generate sources.list files for APT"

    confine :operatingsystem => [:debian, :ubuntu]

    text_line :comment, :match => /^\s*#/, :post_parse => proc { |record|
        record[:name] = $1 if record[:line] =~ /Puppet Name: ([\w\-]+)/
    }

    text_line :blank, :match => /^\s*$/

    record_line :parsed,
        :fields => %w{type uri distribution components},
        :optional => %w{components},
        :rts    => true,
        :match  => %r{^\s*(deb|deb-src)\s+(\S+)\s+(\S+)\s*(.+)?$},
        :post_parse => proc { |h|
            if h[:components].nil?
                h[:components] = [:absent]
            else
                h[:components] = Puppet::Type::Aptrepo::ProviderParsed.parse_components(h[:components])
            end
        }


    def self.prefetch_hook(records)
        name = nil
        result = records.each { |r|
            case r[:record_type]
            when :comment
                if r[:name]
                    name = r[:name]
                    r[:skip] = true
                end
            when :blank
                r[:skip] = true
            else
                if name
                    r[:name] = name
                    name =nil
                end
            end
        }.reject { |r| r[:skip] }
        result
    end

    def self.parse_components(components)
        result = []
        result = components.split(/\s+/)
        result
    end

    def self.to_line(record)
        return super unless record[:record_type] == :parsed
        str = ""
        str = "# Puppet Name: #{record[:name]} (DONOT REMOVE THIS LINE)\n" if record[:name]
        str += "#{record[:type]} #{record[:uri]} #{record[:distribution]}"
        str += " #{record[:components].join(' ')}" if !record[:components].include?(:absent)
        str
    end
end

# vi:ts=4:et:
# EOF
