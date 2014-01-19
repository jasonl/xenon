require 'xenon'

describe Xenon::RouteMap do
  context "A simple route" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "test", :GET, "/tests")
    end
    subject { route_map }

    it "resolves the mapped path correctly" do
      expect(subject.resolve_path("/tests", :GET, {})).to eq("TestController#test")
    end

    it "doesn't resolve other paths" do
      expect(subject.resolve_path("/tests", :POST, {})).to be_nil
      expect(subject.resolve_path("/tests/not_this", :GET, {})).to be_nil
      expect(subject.resolve_path("/else", :GET, {})).to be_nil
    end
  end

  context "A more complex route" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "test", :GET, "/parent/tests")
    end
    subject { route_map }

    it "resolves the mapped path correctly" do
      expect(subject.resolve_path("/parent/tests", :GET, {})).to eq("TestController#test")
    end

    it "doesn't resolve other paths" do
      expect(subject.resolve_path("/parent", :GET, {})).to be_nil
      expect(subject.resolve_path("/parent/tests", :POST, {})).to be_nil
      expect(subject.resolve_path("/parent/else", :POST, {})).to be_nil
      expect(subject.resolve_path("/else/tests", :POST, {})).to be_nil
    end
  end

  context "A really complex route" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "test", :GET, "/parent/tests/rhubarb/cholera")
    end
    subject { route_map }

    it "resolves the mapped path correctly" do
      expect(subject.resolve_path("/parent/tests/rhubarb/cholera", :GET, {})).to eq("TestController#test")
    end
  end

  context "A route with a parameter" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "test", :GET, "/test/:id")
    end
    subject { route_map }

    it "resolves the mapped path and parameters correctly" do
      params = {}
      expect(subject.resolve_path("/test/123", :GET, params)).to eq("TestController#test")
      expect(params[:id]).to eq("123")
    end
  end

  context "A route with two parameters" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "test", :GET, "/test/:first_param/:second_param")
    end
    subject { route_map }

    it "resolves the the mapped path and parameters correctly" do
      params = {}
      expect(subject.resolve_path("/test/123/something", :GET, params)).to eq("TestController#test")
      expect(params[:first_param]).to eq("123")
      expect(params[:second_param]).to eq("something")
    end
  end

  context "A route with a declared route and a parameterised route" do
    let(:route_map) { Xenon::RouteMap.new }
    before do
      route_map.add_mapping("TestController", "new", :GET, "/tests/new")
      route_map.add_mapping("TestController", "show", :GET, "/tests/:id")
    end
    subject { route_map }

    it "resolves preferentially to the non-paramterised route" do
      params = {}
      expect(subject.resolve_path("/tests/new", :GET, params)).to eq("TestController#new")
      expect(params).to be_empty
    end

    it "resolves the paramterised route correctly" do
      params = {}
      expect(subject.resolve_path("/tests/456", :GET, params)).to eq("TestController#show")
      expect(params[:id]).to eq("456")
    end
  end
end
