set :application, "capistrano-file-resources"
set :repository,  "."
set :deploy_to do
  File.join("/home", user, application)
end
set :deploy_via, :copy
set :scm, :none
set :use_sudo, false
set :user, "vagrant"
set :password, "vagrant"
set :ssh_options, {:user_known_hosts_file => "/dev/null"}

role :web, "192.168.33.10"
role :app, "192.168.33.10"
role :db,  "192.168.33.10", :primary => true

$LOAD_PATH.push(File.expand_path("../../lib", File.dirname(__FILE__)))
require "capistrano/configuration/resources/file_resources"
require "stringio"

task(:test_all) {
  find_and_execute_task("test_default")
}

def assert_equals(x, y)
  abort("assert_equals(#{x.dump}, #{y.dump}) failed.") unless x == y
end

def assert_raises(error)
  begin
    yield
  rescue error => e
    logger.debug("assert_raises: expected exception: #{e}")
  end
end

namespace(:test_default) {
  task(:default) {
    methods.grep(/^test_/).each do |m|
      send(m)
    end
  }
  before "test_default", "test_default:setup"
  after "test_default", "test_default:teardown"

  task(:setup) {
    run_locally("mkdir -p tmp")
    run("mkdir -p tmp")
  }

  task(:teardown) {
    run_locally("rm -rf tmp")
    run("rm -rf tmp")
  }

  task(:test_file) {
    run_locally("rm -f tmp/foo; echo foo > tmp/foo")
    assert_equals("foo\n", file("foo", :path => "tmp"))
  }

  task(:test_missing_file) {
    run_locally("rm -f tmp/foo")
    assert_raises(SystemExit) do
      file("foo", :path => "tmp")
    end
  }

  task(:test_file_with_suffix) {
    run_locally("rm -f tmp/foo tmp/foo.erb; echo foo > tmp/foo; echo foo.erb > tmp/foo.erb")
    assert_equals("foo\n", file("foo", :path => "tmp"))
  }

  task(:test_template) {
    run_locally("rm -f tmp/bar; echo bar > tmp/bar")
    assert_equals("bar\n", template("bar", :path => "tmp"))
  }

  task(:test_missing_template) {
    run_locally("rm -f tmp/bar")
    assert_raises(SystemExit) do
      template("bar", :path => "tmp")
    end
  }

  task(:test_template_with_suffix) {
    run_locally("rm -f tmp/bar tmp/bar.erb; echo bar > tmp/bar; echo bar.erb > tmp/bar.erb")
    assert_equals("bar.erb\n", template("bar", :path => "tmp"))
  }

  task(:test_template_rendering) {
    File.write("tmp/baz.erb", %q{<%= "baz" %>})
    assert_equals("baz", template("baz", :path => "tmp"))
  }
}

# vim:set ft=ruby sw=2 ts=2 :
