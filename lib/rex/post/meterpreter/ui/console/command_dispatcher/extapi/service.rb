# -*- coding: binary -*-
require 'rex/post/meterpreter'

module Rex
module Post
module Meterpreter
module Ui

###
#
# Extended API window management user interface.
#
###
class Console::CommandDispatcher::Extapi::Service

  Klass = Console::CommandDispatcher::Extapi::Service

  include Console::CommandDispatcher

  #
  # List of supported commands.
  #
  def commands
    {
      "service_enum" => "Enumerate all registered Windows services",
      "service_query" => "Query more detail about a specific Windows service"
    }
  end

  #
  # Name for this dispatcher
  #
  def name
    "Extapi: Service Management"
  end
  #
  # Options for the service_enum command.
  #
  @@service_enum_opts = Rex::Parser::Arguments.new(
    "-h" => [ false, "Help banner" ]
  )

  #
  # Query a single service for more detail.
  #
  def cmd_service_enum(*args)
    @@service_enum_opts.parse(args) { |opt, idx, val|
      case opt
        when "-h"
          print(
            "\nUsage: service_enum [-h]\n\n" +
            "Enumerate services installed on the target.\n\n" +
            "Enumeration returns the Process ID, Status, and name of each installed\n" +
            "service that was enumerated. The 'Int' value indicates if the service is\n" +
            "able to interact with the desktop.\n\n")
            return true
      end
    }

    status_map = {
      1 => "Stopped",
      2 => "Starting",
      3 => "Stopping",
      4 => "Running",
      5 => "Continuing",
      6 => "Pausing",
      7 => "Paused"
    }

    services = client.extapi.service.enumerate()

    table = Rex::Ui::Text::Table.new(
      'Header'    => 'Service List',
      'Indent'    => 0,
      'SortIndex' => 3,
      'Columns'   => [
        'PID', 'Status', 'Int', 'Name (Display Name)'
      ]
    )

    services.each { |s|
      table << [
        s[:pid],
        status_map[s[:status]],
        s[:interactive] ? "Y" : "N",
        "#{s[:name].downcase} (#{s[:display]})"
      ]
    }

    print_line()
    print_line(table.to_s)
    print_line()
    print_line("Total services: #{services.length}")
    print_line()

    return true
  end

  #
  # Options for the service_query command.
  #
  @@service_query_opts = Rex::Parser::Arguments.new(
    "-h" => [ false, "Help banner" ]
  )

  #
  # Query a single service for more detail.
  #
  def cmd_service_query(*args)
    args << "-h" if args.length == 0

    @@service_query_opts.parse(args) { |opt, idx, val|
      case opt
        when "-h"
          print(
            "\nUsage: service_query [-h] <servicename>\n" +
            "     <servicename>:  The name of the service to query.\n\n" +
            "Gets details information about a particular Windows service, including\n" +
            "binary path, DACL, load order group, start type and more.\n\n")
            return true
      end
    }

    service_name = args.shift

    start_type_map = {
      0 => "Boot",
      1 => "System",
      2 => "Automatic",
      3 => "Manual",
      4 => "Disabled"
    }

    detail = client.extapi.service.query(service_name)

    print_line()
    print_line("Name        : #{service_name}")
    print_line("Display     : #{detail[:display]}")
    print_line("Account     : #{detail[:startname]}")
    print_line("Start Type  : #{start_type_map[detail[:starttype]]}")
    print_line("Path        : #{detail[:path]}")
    print_line("L.O. Group  : #{detail[:logroup]}")
    print_line("Interactive : #{detail[:interactive] ? "Yes" : "No"}")
    print_line("DACL        : #{detail[:dacl]}")
    print_line()

  end

end

end
end
end
end


