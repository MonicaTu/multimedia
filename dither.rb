class BMP
  class Reader
    PIXEL_ARRAY_OFFSET = 1078
    BITS_PER_PIXEL     = 8
    DIB_HEADER_SIZE    = 40

    def initialize(bmp_filename) 
      File.open(bmp_filename, "rb") do |file|
        read_bmp_header(file)
        read_dib_header(file)
        read_pixels(file)
      end
    end

    def [](x,y)
      @pixels[y][x]
    end

    attr_reader :width, :height

    def read_pixels(file)
      @pixels = Array.new(@height) { Array.new(@width) }
      (@height-1).downto(0) do |y|
        0.upto(@width - 1) do |x|
          @pixels[y][x] = file.read(1).unpack("H2").first
        end
        advance_to_next_row(file)
      end
    end

    def advance_to_next_row(file)
      padding_bytes = @width % 4
      return if padding_bytes == 0

      file.pos += padding_bytes
    end

    def read_bmp_header(file)
      header = file.read(14)
      magic_number, file_size, reserved1,
      reserved2, array_location = header.unpack("A2Vv2V")
	p array_location
      
      fail "Not a bitmap file!" unless magic_number == "BM"

      unless file.size == file_size
        fail "Corrupted bitmap: File size is not as expected" 
      end

      unless array_location == PIXEL_ARRAY_OFFSET
        fail "Unsupported bitmap: pixel array does not start where expected"
      end
    end

    def read_dib_header(file)
      header = file.read(40)
      header_size, width, height, planes, bits_per_pixel, 
      compression_method, image_size, hres, 
      vres, n_colors, i_colors = header.unpack("V3v2V6")

      # ^  Note: the right pattern to use is actually "Vl<2v2V2l<2V2",
      # |  but that only works on Ruby 1.9.3+

      unless header_size == DIB_HEADER_SIZE
        fail "Corrupted bitmap: DIB header does not match expected size"
      end

      unless planes == 1
        fail "Corrupted bitmap: Expected 1 plane, got #{planes}"
      end

      unless bits_per_pixel == BITS_PER_PIXEL
        fail "#{bits_per_pixel} bits per pixel bitmaps are not supported"
      end

      unless compression_method == 0
        fail "Bitmap compression not supported"
      end

      unless image_size + PIXEL_ARRAY_OFFSET == file.size
        fail "Corrupted bitmap: pixel array size isn't as expected"
      end

      @width, @height = width, height
    end
  end

  class Writer
    PIXEL_ARRAY_OFFSET = 1078
    BITS_PER_PIXEL     = 8
    DIB_HEADER_SIZE    = 40
    PIXELS_PER_METER   = 2835 # 2835 pixels per meter is basically 72dpi

    def initialize(width, height)
      @width, @height = width, height

      @pixels = Array.new(@height) { Array.new(@width) { "00" } }
    end

    def [](x,y)
      @pixels[y][x]
    end

    def []=(x,y,value)
      @pixels[y][x] = value
    end

    def save_as(filename)
      File.open(filename, "wb") do |file|
        write_bmp_file_header(file)
        write_dib_header(file)
        write_pixel_array(file)
      end
    end

    private

    def write_bmp_file_header(file)
      file << ["BM", file_size, 0, 0, PIXEL_ARRAY_OFFSET].pack("A2Vv2V")
    end

    def file_size
      PIXEL_ARRAY_OFFSET + pixel_array_size 
    end

    def pixel_array_size
      ((BITS_PER_PIXEL*@width)/32.0).ceil*4*@height
    end
   
    # Note: the 'right' pattern to use is actually "Vl<2v2V2l<2V2", but that only works on 1.9.3
    def write_dib_header(file)
      file << [DIB_HEADER_SIZE, @width, @height, 1, BITS_PER_PIXEL,
               0, pixel_array_size, PIXELS_PER_METER, PIXELS_PER_METER, 
               0, 0].pack("V3v2V6")
    end

    def write_pixel_array(file)
      @pixels.reverse_each do |row|
        row.each do |color|
          file << pixel_binstring(color)
          #file << color
        end

        #file << row_padding
      end
    end

    def pixel_binstring(rgb_string)
      #raise ArgumentError unless rgb_string =~ /\A\h{2}\z/
      [rgb_string].pack("H2")
    end

    def row_padding
      "\x0" * (@width % 4)
    end
  end
end

bmp = BMP::Reader.new(ARGV[1])

p bmp.width  #=> show width of bmp
p bmp.height #=> show height of bmp

bmp_w = BMP::Writer.new(bmp.width,bmp.height)

#(bmp.height-1).downto(0) do |y|
#        0.upto(bmp.width - 1) do |x|
#	  bmp_w[x,y] = (bmp[x,y].hex).to_s(16)
#	end
#end

n = ARGV[0].to_i
shift = 0

case n
    when 2
        shift = 6
        DM = [[0, 2],
              [3, 1]]
    when 4
        shift = 4
        DM = [[0, 8, 2, 10], 
              [2, 4, 14, 6], 
              [3, 11, 1, 9], 
              [15, 7, 13, 5]]
    else
        puts "No #{n}x#{n} dithering matrix support."
end
0.upto(bmp.height - 1) do |y|
	i = y % n
	0.upto(bmp.width - 1) do |x|
		j = x % n
		if (bmp[x,y].hex>>shift) > DM[j][i]
			bmp_w[x,y] = "ff"
		else
			bmp_w[x,y] = "0"
		end
       end
end
bmp_w.save_as(ARGV[2])
