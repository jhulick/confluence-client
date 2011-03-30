require 'spec_helper'

describe "Confluence" do

  before(:each) do
    @url  = 'http://example.org'
    @user = 'user'
    @pass = 'password'
  end


  describe "Client initialization" do

    context "with no arguments" do
      it "should raise ArgumentError" do
        lambda { Confluence::Client.new }.should raise_error(ArgumentError)
      end
    end

    context "with one argument" do
      
      context "that is invalid" do
        it "should raise ArgumentError when nil" do
          lambda { Confluence::Client.new(nil) }.should raise_error(ArgumentError)
        end
        it "should raise ArgumentError when blank" do
          lambda { Confluence::Client.new('') }.should raise_error(ArgumentError)
        end
      end

      context "that is string" do
        it "should raise RuntimeError when not a URL" do
          lambda { Confluence::Client.new(@user) }.should raise_error(RuntimeError, 'Wrong URI as parameter!' )
        end
        it "should not raise errors when given URL" do
          lambda { Confluence::Client.new(@url) }.should_not raise_error
        end
      end

    end

  end


  describe "Client#login" do

    before(:each) do
      @confluence = Confluence::Client.new(@url)
    end
    
    context "with invalid arguments" do
      it "should raise ArgumentError with no arguments" do
        lambda { @confluence.login() }.should raise_error(ArgumentError)
      end
      it "should raise ArgumentError with not enough arguments" do
        lambda { @confluence.login(@user) }.should raise_error(ArgumentError)
      end
      it "should raise ArgumentError with too many arguments" do
        lambda { @confluence.login(@user, @pass, @pass) }.should raise_error(ArgumentError)
      end
      it "should raise ArgumentError when :user is nil" do
        lambda { @confluence.login(nil, @pass) }.should raise_error(ArgumentError)
      end
      it "should raise ArgumentError when :password is nil" do
        lambda { @confluence.login(@user, nil) }.should raise_error(ArgumentError)
      end
    end

    context "with successful login" do
      it "should return security token" do
        token = 'some security token'
        @confluence.stub(:login).with(@user, @pass) { token }
        @confluence.login(@user, @pass).should be(token)
      end
    end

    context "with unsuccessful login" do
      it "should raise XMLRPC::FaultException" do
        @confluence.should_receive(:login).with(@user, @pass).and_raise( XMLRPC::FaultException.new(:faultCode, :faultString) )
        lambda { @confluence.login(@user, @pass) }.should raise_error(XMLRPC::FaultException)
      end
    end

  end

end

