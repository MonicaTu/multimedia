%Extended Huffman 
prob=0.1;
m=4;

%Generating the probabilities

for i = 1:2^m
  q(i) = 1;

  for j=0: m-1
    b=2^j;

    if bitand(i-1,b)
      q(i)= q(i)*prob;
    else 
      q(i)= q(i)*(1-prob);
    end
  end
end


disp ('Sum of probabilities');
disp (sum(q));

disp('Entropy per symbol');%should be equal to 1
E=sum(q.*log2(1./q));

disp(E/m); 


%huffman 

s=0:2^m-1; %There are 16 symbols from 0000 -> 1111
[dict,avglen] = huffmandict(s,q); %probabilities

for j=(0:4:1000-1)
    newcode=message(j+1:j+4); %Dividing the message into 4 bits and saving the     
    %corresponding decimal values
    array(:,a)=bi2de(newcode);
    a=a+1;
end

for(f=1:250)
  for(i=1:15)
    if(array(f)==cell2mat((dict(i,1)))) %cell2mat will obtain the value of the cell
      encodedmsg= horzcat(encodedmsg, dict(i,2)); %horzcat will concatenate the array                    with its corresponding codeword
    end
  end
end
