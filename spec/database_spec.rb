require 'spec_helper'

describe Xenon::Database do
  describe ".quote_identifier" do
    it "should quote a normal identifier" do
      expect(Xenon::Database.quote_identifier("id")).to eq(%q{"id"})
    end

    it "should quote a null identifier" do
      expect(Xenon::Database.quote_identifier("")).to eq(%q{""})
    end
  end

  describe ".quote_value" do
    context "passing an integer" do
      it "should not quote an integer" do
        expect(Xenon::Database.quote_value(12345, :integer)).to eq("12345")
      end

      it "should return NULL when passed nil" do
        expect(Xenon::Database.quote_value(nil, :integer)).to eq("NULL")
      end

      it "should return 0 when passed text" do
        expect(Xenon::Database.quote_value("test", :integer)).to eq("0")
      end

      it "should return 0 when passed malicious text" do
        expect(Xenon::Database.quote_value("'; DROP TABLE test", :integer)).to eq("0")
      end
    end

    context "passing a string" do
      it "should quote an ordinary string" do
        expect(Xenon::Database.quote_value("test", :string)).to eq("'test'")
      end

      it "should correctly quote a single quote" do
        expect(Xenon::Database.quote_value("o'test", :string)).to eq("'o''test'")
      end

      it "should correctly quote the empty string" do
        expect(Xenon::Database.quote_value("", :string)).to eq("''")
      end

      it "should return NULL for nil" do
        expect(Xenon::Database.quote_value(nil, :string)).to eq("NULL")
      end
    end

    context "passing text" do
      it "should quote an ordinary string" do
        expect(Xenon::Database.quote_value("test", :text)).to eq("'test'")
      end

      it "should correctly quote a single quote" do
        expect(Xenon::Database.quote_value("o'test", :text)).to eq("'o''test'")
      end

      it "should correctly quote the empty string" do
        expect(Xenon::Database.quote_value("", :text)).to eq("''")
      end

      it "should return NULL for nil" do
        expect(Xenon::Database.quote_value(nil, :text)).to eq("NULL")
      end
    end
  end
end
