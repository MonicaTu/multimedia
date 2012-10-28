require "write_bmp8bit.rb"
require "write_bmp24bit.rb"

class BMP
  class Reader
    PIXEL_ARRAY_OFFSET = 54
    BITS_PER_PIXEL     = 24
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
        	@pixels[y][x] = file.read(3).unpack("H6").first
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
end

bmp = BMP::Reader.new("Baboon.bmp")

p bmp.width  #=> show width of bmp
p bmp.height #=> show height of bmp

only_y_bmp_w = BMP8::Writer.new(bmp.width,bmp.height)
only_cb_bmp_w = BMP8::Writer.new(bmp.width,bmp.height)
only_cr_bmp_w = BMP8::Writer.new(bmp.width,bmp.height)
comp_ycbcr_bmp_w = BMP24::Writer.new(bmp.width,bmp.height)

#(bmp.height-1).downto(0) do |y|
#        0.upto(bmp.width - 1) do |x|
#	  bmp_w[x,y] = (bmp[x,y].hex).to_s(16)
#	end
#end

0.upto(bmp.height - 1) do |x|
	0.upto(bmp.width - 1) do |y|
		fB=bmp[x,y][0..1]
		fG=bmp[x,y][2..3]
		fR=bmp[x,y][4..5]
### Method 1 work! ###
		fY=sprintf("%.0f",0.299*fR.hex + 0.587*fG.hex + 0.114*fB.hex)
		fCB=sprintf("%.0f",128+ -0.168736*fR.hex - 0.331264*fG.hex + 0.5*fB.hex)
		fCR=sprintf("%.0f",128+ 0.5*fR.hex - 0.418688*fG.hex - 0.081312*fB.hex)
		ycbcr=sprintf("%.2X%.2X%.2X",fCR,fCB,fY)
		hY=sprintf("%.2X",fY)
		hCB=sprintf("%.2X",fCB)
		hCR=sprintf("%.2X",fCR)
### Method 2 did not work yet ###
#        Y=16+ ((65.481*R) + (128.553*G) + (24.966*B))/256;
#        CB=128+ ((-37.797*R) - (74.203*G) + (112*B))/256;
#        CR=128+ ((112*R) - (93.798*G) - (18.214*B))/256;
#        only_y(i,j)=Y;
#        only_cb(i,j)=CB;
#        only_cr(i,j)=CR;
#        comb_ycbcr{i,j,:)=[Y,CB,CR];
		only_y_bmp_w[x,y] = hY
		only_cb_bmp_w[x,y] = hCB
		only_cr_bmp_w[x,y] = hCR
		comp_ycbcr_bmp_w[x,y] = ycbcr
       end
end
only_y_bmp_w.save_as("only_y.bmp")
only_cb_bmp_w.save_as("only_cb.bmp")
only_cr_bmp_w.save_as("only_cr.bmp")
comp_ycbcr_bmp_w.save_as("comp_ycbcr.bmp")

