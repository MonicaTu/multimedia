%[dict,avglen] = huffmandict([1:6],[.5 .125 .125 .125 .0625 .0625]);
%sig = [ 2 1 4 2 1 1 5 4 ];
%sig_encoded = huffmanenco(sig,dict)

%sig = {'a2', 44, 'a3', 55, 'a1'}
%dict = {'a1',[0]; 'a2',[1,0]; 'a3',[1,1,0]; 44,[1,1,1,0]; 55,[1,1,1,1]}
%sig_encoded = huffmanenco(sig,dict)

clear;

size = 100;
num = 9;
inStr = round(random('unif',1,num,1,size))

tic
m = 1;
n = 1;
word(1:size) = 0;
word_cnt(1:size) = 0;

for i = 1:size
    loc = findstr(inStr(i), word);
    if isempty(loc);
        word(m) = inStr(i);
        word_cnt(m) = word_cnt(m) + 1;
        m = m + 1;
    else
        n = loc(1);
        word_cnt(n) = word_cnt(n) + 1;
    end
end

for i = 1:(m-1)
    words(i) = word(i);
    probs(i) = word_cnt(i)/size;
end
toc

tic
% genetic Huffman
[dict, avglen] = huffmandict(words, probs);
sig_encoded = huffmanenco(inStr, dict);
toc

src_size = size * round(log2(size))
enc_size = length(sig_encoded)
src_size/enc_size

tic
% extended Huffman
i = 1;
j = 1;
k = 1;
for i = 1:(m-1)
    for j = 1:(m-1)
        words2(k) = str2num([num2str(words(i)),num2str(words(j))]);
        probs2(k) = (word_cnt(i)/size) * (word_cnt(j)/size);
        %words2 = str2num([num2str(words(i)),num2str(words(j))])
        %probs2 = (word_cnt(i)/size) * (word_cnt(j)/size)
        k = k + 1;
    end
end
j = 1;
%for i = 1:m/2
%    words2(i) = extended_inStr;
%    probs2(i) = (word_cnt(i)/size) * (word_cnt(j+1)/size);
%    j = j + 2;
%end
for i = 0:(size/2-1)
    inStr2 = str2num([num2str(inStr(2*i+1)),num2str(inStr(2*i+2))]);
end
[dict, avglen] = huffmandict(words2, probs2);
extended_sig_encoded = huffmanenco(inStr2, dict);
toc

extended_enc_size = length(sig_encoded)
src_size/extended_enc_size

tic
% adaptive Huffman
huffstream = adaptivehuffman(uint8(inStr), 'enc');
toc
adaptive_enc_size = length(huffstream)
src_size/adaptive_enc_size