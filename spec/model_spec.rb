require 'spec_helper'

describe Xenon::Model do
  before(:all) do
    class Post < Xenon::Model
      primary_key :id
      string :title
      text   :body
    end
  end

  describe "Class methods" do
    subject { Post }

    context "Basic information" do
      it "should have a table_name method" do
        expect(subject).to respond_to(:table_name)
      end

      it "should correctly pluralise the table name" do
        expect(subject.table_name).to eq("posts")
      end

      it "should have a primary_key method" do
        expect(subject).to respond_to(:primary_key)
      end

      it "should return the primarykey" do
        expect(subject._primary_key).to eq(subject.columns[:id])
      end      
    end

    describe "Model.table_exists?" do
      context "when the table exists" do
        before do
          expect(Xenon::Database).to receive(:execute).
            with("SELECT COUNT(*) FROM pg_class WHERE relname='posts' AND relkind='r'").
            and_return([{"count" => "1"}])
        end
        
        it "returns true" do
          expect(Post.table_exists?).to eq(true)
        end
      end
      
      context "when the table doesn't exist" do
        before do
          expect(Xenon::Database).to receive(:execute).
            with("SELECT COUNT(*) FROM pg_class WHERE relname='posts' AND relkind='r'").
            and_return([{"count" => "0"}])
        end
        
        it "returns false" do
          expect(Post.table_exists?).to eq(false)
        end
      end
    end

    describe "Model.create_table" do
      it "executes the correct SQL to create the table" do
        expect(Xenon::Database).to receive(:execute).
          with("CREATE TABLE posts (id INTEGER PRIMARY KEY, title VARCHAR(255), body TEXT);")
        Post.create_table
      end
    end
    
    describe "Model.add_column" do
      let(:column) { Xenon::Column.new("test_col", :type => :string) }
      
      it "executes the correct SQL to add a column" do
        expect(Xenon::Database).to receive(:execute).
          with("ALTER TABLE posts ADD COLUMN test_col VARCHAR(255)")
        Post.add_column(column)
      end
    end

    describe "Model.drop_column" do
      it "executes the correct SQL to drop a column" do
        expect(Xenon::Database).to receive(:execute).
          with("ALTER TABLE posts DROP COLUMN test_col")
        Post.drop_column("test_col")
      end
    end

    context "Instantiation" do
      it "should be able to be instantiated without parameters" do
        expect(Post.new).to be_a(Post)
      end

      context "it should be able to be instantiated with paramters" do
        subject { Post.new(title:"Test Title") }

        it "should be a Post object" do
          expect(subject).to be_a(Post)
        end

        it "should set the title attribute" do
          expect(subject.title).to eq("Test Title")
        end
      end
    end
  end

  describe "dynamic attribute methods" do
    subject { Post.new }

    it "should have the correct dynamically defined attribute methods" do
      expect(subject).to respond_to(:id)
      expect(subject).to respond_to(:id=)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:title=)
      expect(subject).to respond_to(:body)
      expect(subject).to respond_to(:body=)
    end
  end



  describe "Model.read" do
    context "where the database row exists" do
      before do
        Xenon::Database.execute("DROP TABLE IF EXISTS #{Post.table_name}")
        Xenon::Database.execute(Post.create_table_sql)
        Xenon::Database.execute("INSERT INTO #{Post.table_name} (id, title, body) VALUES (1, 'Test Title', 'Test Body');")
      end

      subject { Post.read(1) }

      it "should instantiate a Post model" do
        expect(subject).to be_a(Post)
      end

      it "should correctly instantiate the attributes" do
        expect(subject.id).to eq(1)
        expect(subject.title).to eq("Test Title")
        expect(subject.body).to eq("Test Body")
      end
    end

    context "where the database row doesn't exist" do
      before do
        Xenon::Database.execute("DROP TABLE IF EXISTS #{Post.table_name}")
        Xenon::Database.execute(Post.create_table_sql)
        Xenon::Database.execute("DELETE FROM #{Post.table_name}")
      end

      subject { Post.read(1) }

      it "should return nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "Model.create" do
    before do
      Xenon::Database.execute("DROP TABLE IF EXISTS #{Post.table_name}")
      Xenon::Database.execute(Post.create_table_sql)
      Xenon::Database.execute("DELETE FROM #{Post.table_name}")
    end

    subject { Post.create(id: 1, title: "Test Title", body: "Test Body") }

    it "should instantiate and instance and return it" do
      expect(subject).to be_a(Post)
    end

    it "should set the attributes of the returned instance" do
      expect(subject.id).to eq(1)
      expect(subject.title).to eq("Test Title")
      expect(subject.body).to eq("Test Body")
    end

    context "setting the fields of the database row" do
      before { Post.create(id: 1, title: "Test Title", body: "Test Body") }
      subject { Xenon::Database.execute("SELECT * FROM #{Post.table_name}")[0] }

      it "should set them to the values passed" do
        expect(subject['id']).to eq("1")
        expect(subject['title']).to eq("Test Title")
        expect(subject['body']).to eq("Test Body")
      end
    end
  end

  describe "Model.update" do
    before do
      Xenon::Database.execute("DROP TABLE IF EXISTS #{Post.table_name}")
      Xenon::Database.execute(Post.create_table_sql)
      Post.create(id:1, title:"Test Title", body:"Test Body")
    end

    subject { Post.update(1, title:"Modified Title") }

    it "should be a Post instance" do
      expect(subject).to be_a(Post)
    end

    it "has the updated attribute" do
      expect(subject.title).to eq("Modified Title")
    end

    it "leaves other attributes unchanged" do
      expect(subject.id).to eq(1)
      expect(subject.body).to eq("Test Body")
    end

    describe "updating the database row" do
      before { Post.update(1, title:"Modified Title") }
      subject { Xenon::Database.execute("SELECT * FROM #{Post.table_name} WHERE id = 1")[0] }

      it "updates only those attributes specified" do
        expect(subject['id']).to eq("1")
        expect(subject['title']).to eq("Modified Title")
        expect(subject['body']).to eq("Test Body")
      end
    end
  end

  context "instance methods" do
    subject { Post.new }

    it "returns the correct table name" do
      expect(subject.send(:_table_name)).to eq("posts")
    end

    it "returns the primary key" do
      expect(subject.send(:_primary_key)).to be
    end

    describe "#update" do
      before do
        Xenon::Database.execute("DROP TABLE IF EXISTS #{Post.table_name}")
        Xenon::Database.execute(Post.create_table_sql)
      end
      
      let(:post) { Post.create(id:1, title:"Test Title", body:"Test Body") }
      subject { post.update(title:"New Title") }

      it "updates the model attributes" do
        expect(subject).to be_a(Post)
        expect(subject.title).to eq("New Title")
      end

      describe "updating the database row" do
        before { post.update(title:"New Title") }
        subject { Xenon::Database.execute("SELECT * FROM #{Post.table_name} WHERE id = 1")[0] }

        it "changes only those columns that have changed" do
          expect(subject['id']).to eq("1")
          expect(subject['title']).to eq("New Title")
          expect(subject['body']).to eq("Test Body")
        end
      end
    end
  end
end
