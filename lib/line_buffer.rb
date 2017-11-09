class LineBuffer
  def initialize(options = {})
    @encoding = options[:encoding] || DEFAULT_ENCODING
    @buffer = ''.force_encoding(Encoding::BINARY)
    @cut_offset = @index_offset = 0
  end

  def <<(chunk)
    @buffer << chunk
  end

  def get(&block)
    @buffer.force_encoding(Encoding::BINARY)
    while (i = @buffer.index(NEWLINE, @index_offset))
      yield @buffer[@cut_offset, i-@cut_offset+1].force_encoding(@encoding)
      @index_offset = @cut_offset = i+1
    end
    @buffer.slice!(0, @cut_offset)
    @index_offset = @buffer.size
    @cut_offset = 0
  end

  def done?
    @buffer.empty?
  end

  NEWLINE = "\n".force_encoding(Encoding::BINARY).freeze
  DEFAULT_ENCODING = Encoding::UTF_8
end