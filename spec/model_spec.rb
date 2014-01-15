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
        expect(subject._primary_key).to eq(subject.columns['id'])
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

  describe "Model.create_table_sql" do
    subject { Post.create_table_sql }
    it "should generate the correct SQL to create the table" do
      expect(subject).to eq("DROP TABLE IF EXISTS posts; CREATE TABLE posts (id INTEGER PRIMARY KEY, title VARCHAR(255), body TEXT);")
    end
  end

  describe "Model.read" do
    context "where the database row exists" do
      before do
        Xenon::Database.connection.exec(Post.create_table_sql)
        Xenon::Database.connection.exec("INSERT INTO #{Post.table_name} (id, title, body) VALUES (1, 'Test Title', 'Test Body');")
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
        Xenon::Database.connection.exec(Post.create_table_sql)
        Xenon::Database.connection.exec("DELETE FROM #{Post.table_name}")
      end

      subject { Post.read(1) }

      it "should return nil" do
        expect(subject).to be_nil
      end
    end
  end

  context "instance methods" do
    subject { Post.new }

  end
end
