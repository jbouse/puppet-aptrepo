require 'puppet/provider/parsedfile'

Puppet::Type.type(:aptrepo).provide(:parsed,
    :parent => Puppet::Provider::ParsedFile,
    :filetype => :flat,
    :default_target => ''
) do
    desc "Parse and generate sources.list files for APT"

    confine :operatingsystem => [:debian, :ubuntu]

    text_line :comment, :match => /^#/
    text_line :blank, :match => /^\s*$/

    record_line :parsed, 
        :fields => %w{type uri distribution components},
        :optional => %w{components},
        :rts    => true,
        :match  => /^(deb|deb-src) ([^ ]+) ([^ ]+)(?: (.+))?$/,
        :post_parse => proc { |h|
            if h[:components].nil?
                h[:components] = [:absent]
            else
                h[:components] = Puppet::Type::Aptrepo::ProviderParsed.parse_components(h[:components])
            end
        },
        :pre_gen => proc { |h|
            if h[:components].include?(:absent)
                h[:components] = ""
            else
                h[:components] = h[:components].join(" ")
            end
        }

    def target
            @resource.should(:target) 
    end

    def dir_perm
        if target
            0755
        end
    end

    def file_perm
        if target
            0644
        end
    end

    def flush
        if target
            dir = File.dirname(target)
            if not File.exists? dir
                Puppet.debug("Creating directory %s which does not exist" % dir)
                Dir.mkdir(dir, dir_perm)
            end
        end

        super

        if target
            File.chmod(file_perm, target)
        end
    end

    def self.parse_components(components)
        result = []
        result = components.split(/\s+/)
        result
    end
end

# vi:ts=4:et:
# EOF
