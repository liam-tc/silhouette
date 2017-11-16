require 'securerandom'

module Silhouette
  class Profile
    def initialize 
      @call_events = []
      @timing_events = []
      init_method_call_trace
      init_method_return_trace
    end

    def init_method_call_trace
      TracePoint.trace :call do |tp|
        unless tp.defined_class.name.to_s == self.class.name 
          puts ""
          p "CALL EVENT"
          p tp.method_id
          p @call_events
          @call_events << [Time.now.to_f, SecureRandom.uuid]
        end
      end
    end

    def init_method_return_trace
      TracePoint.trace :return do |tp|
        unless tp.defined_class.to_s == self.class.name
          puts ""
          p "RETURN EVENT"
          p tp.method_id
          p @call_events
          p tp.defined_class
          p tp.event
          p tp.lineno
          p tp.return_value
          current = @call_events.last.last
          time_elapsed = Time.now.to_f - @call_events.pop.first
          @timing_events << { method_name: tp.method_id, call_uuid: current, parent: @call_events.last.last, time: time_elapsed }
        end
      end
    end

    def build_tree
      root = {method_name: 'root', call_uuid: nil, time: 0, children: []}

      build_tree_r root, @timing_events
    end

    def build_tree_r root, leaves 
      root.children = leaves.select { |l| l[:parent] == root[:call_uuid] }
      remaining_leaves = leaves - root.children
      root.children.each do |c|
        build_tree_r c, remaining_leaves
      end
      root
    end

    def show_events
      p build_tree
    end
  end
end

