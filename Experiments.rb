require 'active_record'
require 'object_tracker'
require 'conflict_analysis'
require 'objspace'

=begin
ObjectSpace::each_object do |e|
  puts (e.to_s)
end
=end

configuration = YAML::load(IO.read('config/database.yml'))
ConflictAnalysis.init(configuration['development'], {:strict => true})

#A = Class.new {include Amb}.new

require_relative 'app/models/user'
require_relative 'app/models/micropost'


class Micropost
  extend ObjectTracker
  def initialize(attrs={})
    super
    $ARS.push(self)
    puts "Micropost initialized with #{attrs}"
  end
  def do_validate
    self.perform_validations
  end
  def send(*attr)
    #puts "Sent for attr: #{attr}"
    x = super
    x
  end

  def instrument(res)
    puts "User::allocate returned #{res}"
  end
end

class User
  def initialize(attrs={})
    super
    $ARS.push self
  end
end

$ARS = []
at_exit do
  ConflictAnalysis.tracer.end_all
end
=begin
set_trace_func proc { |event, file, line, id, binding, classname|
  if event == "call"  && caller_locations.length > 500
    fail "stack level too deep"
  end
}
=end
ConflictAnalysis.with_args_of_type User, Micropost, lambda {|user, post|
=begin
  Process.fork do
    post.save
  end
  Process.wait
=end
  #user.save
  post.save
}

#$instrument = lambda {|res| puts "Res is #{res}"}

#puts ENV.to_hash.to_yaml

#Micropost.track_all!
#User.track_with(:allocate => lambda { |i| i})
#Micropost.track_with(:allocate => lambda { |i| i})
#puts SymbolicUserId.methods
#SymbolicUserId.track_all!
#sym_uid = SymbolicUntyped.new("post.user_id")#.extend ObjectTracker
#sym_uid.track_all!

#post = Micropost.new
# post.id does not matter. System creates a new id.
#post.id=:sym_id
#post.content=:sym_content
# post.user_id is most important.
#post.user_id=sym_uid
#post.created_at=:sym_created_at
#post.updated_at=:sym_updated_at
#post.do_validate
# Until this point, whatever we wrote are retained.
#post.save