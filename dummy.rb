require './silhouette'
require 'json'

def dummy1
  sleep 1
end

def dummy2 i 
  if i < 1 then
    return
  end
  dummy1
  dummy2 (i - 1)
end

def dummy3
  dummy2 10
  dummy2 3
  return 2
end

pr = Silhouette::Profile.new
dummy3
pr.disable
output = pr.show_events
json = JSON.generate(output)
File.write('./ex.json', json)

