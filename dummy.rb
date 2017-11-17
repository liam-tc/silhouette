require './silhouette'

def dummy1
  sleep 1
end

def dummy2 
  dummy1
end

def dummy3
  dummy2
  dummy2
  return 2
end

pr = Silhouette::Profile.new
dummy3
pr.disable
pr.show_events

