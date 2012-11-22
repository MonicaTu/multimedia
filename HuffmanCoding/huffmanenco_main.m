%[dict,avglen] = huffmandict([1:6],[.5 .125 .125 .125 .0625 .0625]);
%sig = [ 2 1 4 2 1 1 5 4 ];
%sig_encoded = huffmanenco(sig,dict)

%stream = [12 13 14 15];
%huffstream = adaptivehuffman(stream,'enc')

%sig = {'a2', 44, 'a3', 55, 'a1'}
%dict = {'a1',[0]; 'a2',[1,0]; 'a3',[1,1,0]; 44,[1,1,1,0]; 55,[1,1,1,1]}
%sig_encoded = huffmanenco(sig,dict)

clear;

inStr = input('Input a string: ', 's');
size = length(inStr);
m = 1;
n = 1;
word(1:size) = 0;
word_cnt(1:size) = 0;

for i = 1:size
    loc = findstr(inStr(i), word)
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

[dict, avglen] = huffmandict(words, probs);
sig_encoded = huffmanenco(inStr, dict)

src_size = size * 5
enc_size = length(sig_encoded)
src_size/enc_size
