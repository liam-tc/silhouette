require 'securerandom'
require 'pp'

module Silhouette
  class Profile
    def initialize 
      @call_events = []
      @timing_events = []
      @tps = []
      init_method_call_trace
      init_method_return_trace
    end

    def init_method_call_trace
      @tps << TracePoint.trace(:call) do |tp|
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
      @tps << TracePoint.trace(:return) do |tp|
        unless tp.defined_class.to_s == self.class.name || @call_events.empty?
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
          parent = @call_events.last ? @call_events.last.last : nil
          @timing_events << { method_name: tp.method_id, call_uuid: current, parent: parent, time: time_elapsed }
        end
      end
    end

    def disable
      @tps.each { |tp| tp.disable }
    end

    def build_tree
      root = {method_name: 'root', call_uuid: nil, time: 0, children: []}

      build_tree_r root, @timing_events
    end

    def build_tree_r root, leaves 
      root[:children] = leaves.select { |l| l[:parent] == root[:call_uuid] }
      remaining_leaves = leaves - root[:children]
      root[:children].each do |c|
        build_tree_r c, remaining_leaves
      end
      root
    end

    def show_events
      pp build_tree
    end
  end
end

