module Puppet
    newtype(:aptrepo) do
        @doc = "Manages APT repositories."

        @@sources_list = "/etc/apt/sources.list"
        @@sources_list_d = "/etc/apt/sources.list.d"

        ensurable

        newparam(:name) do
            desc "The APT repository name."

            isnamevar

            validate do |value|
                if value =~ /\s/
                    raise Puppet::Error, "APT repository name cannot include whitespace"
                end
            end
        end

        newproperty(:type) do
            desc "The type of repository."

            newvalue("deb")
            newvalue("deb-src")

            aliasvalue(:bin, "deb")
            aliasvalue(:src, "deb-src")
        end

        newproperty(:distribution) do
            desc "APT distrbution to use."

            newvalue(:absent) { self.should = :absent }
            newvalue(/.*/) { }

            validate do |value|
                if value =~ /\s/
                    raise Puppet::Error, "APT repository distribution cannot include whitespace"
                end
            end
        end

        newproperty(:components, :array_matching => :all) do
            desc "APT repository distribution components"

            def insync?(is)
                is == @should
            end

            def is_to_s(value)
                if value == :absent or value.include?(:absent)
                    super
                else
                    value.join(" ")
                end
            end

            def should_to_s(value)
                if value == :absent or value.include?(:absent)
                    super
                else
                    value.join(" ")
                end
            end
        end

        newproperty(:uri) do
            desc "APT repository URI"

            newvalue(:absent) { self.should = :absent }
            newvalue(/.*/) { }
        end

        newproperty(:target) do
            desc "The file in which to store the APT repository listing."

            defaultto :absent

            def should
                if defined? @should and @should[0] != :absent
                    return super
                end

                return File.join(@@sources_list_d.to_s, "#{@resource[:name]}.list")
            end

            def insync?(is)
                is == should
            end
        end

    end
end

# vi:ts=4:et:
# EOF
