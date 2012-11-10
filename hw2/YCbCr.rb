require "bmp24_reader.rb"
require "write_bmp8bit.rb"
require "write_bmp24bit.rb"

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

