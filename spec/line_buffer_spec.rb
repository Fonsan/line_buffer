require 'spec_helper'
describe LineBuffer do
  let :line_buffer do
    described_class.new
  end

  describe '#get' do
    before do
      line_buffer << "alpha\nbravo\ncharlie"
    end

    let :lines do
      []
    end

    it 'it only yields complete lines' do
      line_buffer.get { |line| lines << line }
      lines.should == ["alpha\n", "bravo\n"]
    end

    it 'yields all new complete lines every time' do
      line_buffer << "\n"
      line_buffer.get { |line| lines << line }
      lines.should == ["alpha\n", "bravo\n", "charlie\n"]
    end

    it 'works for lines split over multiple chunks' do
      line_buffer << "\ndel"
      line_buffer.enum_for(:get).to_a.should == ["alpha\n", "bravo\n", "charlie\n"]
      line_buffer << "ta\ne"
      line_buffer.enum_for(:get).to_a.should == ["delta\n"]
      line_buffer << "cho"
      line_buffer.enum_for(:get).to_a.should == []
      line_buffer << "\n"
      line_buffer.enum_for(:get).to_a.should == ["echo\n"]
    end

    it 'encodes lines with provided encoding' do
      line_buffer = described_class.new(encoding: Encoding::IBM852)
      line_buffer << "alpha\n"
      line_buffer.get { |line| lines << line }
      lines.should_not be_empty
      lines.each { |line| line.encoding.should == Encoding::IBM852 }
    end

    it "uses default encoding #{described_class::DEFAULT_ENCODING} unless explicitly set" do
      line_buffer.get { |line| lines << line }
      lines.should_not be_empty
      lines.each { |line| line.encoding.should == described_class::DEFAULT_ENCODING }
    end
  end

  describe '#done?' do
    it 'returns true if no chunks has been added' do
      line_buffer.should be_done
    end

    it 'returns true if all inputted data has been gotten' do
      line_buffer << "alpha\nbravo\n"
      line_buffer.get {}
      line_buffer.should be_done
    end

    it 'returns false if no inputted data has been gotten' do
      line_buffer << "alpha\nbravo"
      line_buffer.should_not be_done
    end

    it 'returns false if incomplete line is left' do
      line_buffer << "alpha\nbravo"
      line_buffer.get {}
      line_buffer.should_not be_done
    end
  end
end