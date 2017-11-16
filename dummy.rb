require './silhouette'

def dummy1
  x = []
end

def dummy2 
  dummy1
end

def dummy3
  dummy2
  return 2
end

pr = Silhouette::Profile.new
dummy1

