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
set :ssh_options, {
  :auth_methods => %w(publickey password),
  :keys => File.join(ENV["HOME"], ".vagrant.d", "insecure_private_key"),
  :user_known_hosts_file => "/dev/null"
}

role :web, "192.168.33.10"
role :app, "192.168.33.10"
role :db,  "192.168.33.10", :primary => true

$LOAD_PATH.push(File.expand_path("../../lib", File.dirname(__FILE__)))
require "capistrano/configuration/resources/file_resources"
require "tempfile"

task(:test_all) {
  find_and_execute_task("test_default")
}

def assert_equals(x, y, options={})
  begin
    raise if x != y
  rescue
    logger.debug("assert_equals(#{x.dump}, #{y.dump}) failed.")
    raise
  end
end

def assert_raises(error, options={})
  begin
    yield
  rescue error => e
    raised = e
  ensure
    if raised
      logger.debug("assert_raises(#{error}) expected exception: #{raised}")
    else
      raise("assert raises(#{error}) failed.")
    end
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
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/foo", "foo")
    assert_equals(file("foo", :path => "tmp"), "foo")
  }

  task(:test_missing_file) {
    run_locally("rm -rf tmp; mkdir tmp")
    assert_raises(SystemExit) do
      file("foo", :path => "tmp")
    end
  }

  task(:test_file_with_suffix) {
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/foo", "foo")
    File.write("tmp/foo.erb", "foo.erb")
    assert_equals(file("foo", :path => "tmp"), "foo")

  }

  task(:test_template) {
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/bar", "bar")
    assert_equals(template("bar", :path => "tmp"), "bar")
  }

  task(:test_missing_template) {
    run_locally("rm -rf tmp; mkdir tmp")
    assert_raises(SystemExit) do
      template("bar", :path => "tmp")
    end
  }

  task(:test_template_with_suffix) {
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/bar", "bar")
    File.write("tmp/bar.erb", "bar.erb")
    assert_equals(template("bar", :path => "tmp"), "bar.erb")
  }

  task(:test_template_with_suffix_rhtml) {
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/bar.rhtml", "bar.rhtml")
    assert_equals(template("bar.html", :path => "tmp"), "bar.rhtml")
  }

  task(:test_template_rendering) {
    run_locally("rm -rf tmp; mkdir tmp")
    File.write("tmp/baz.erb", %q{<%= "baz" %>})
    assert_equals(template("baz", :path => "tmp"), "baz")
  }
}

# vim:set ft=ruby sw=2 ts=2 :
