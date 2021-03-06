	tic
M1 = dlmread('1503959170110.txt',',');
N1 = dlmread('1503959170110_IMU.txt',',');
O1 = dlmread('1503959170110_EMG.txt',',');
M2 = dlmread('1503958514022.txt',',');
N2 = dlmread('1503958514022_IMU.txt',',');
O2 = dlmread('1503958514022_EMG.txt',',');
dataFork1=dataforPCA1(M1,N1,O1);
dataSpoon1=dataforPCA1(M2,N2,O2);
dataFork0=dataforPCA0(M1,N1,O1);
dataSpoon0=dataforPCA0(M2,N2,O2);
data1=[dataFork1;dataSpoon1];
data0=[dataFork0;dataSpoon0];
A=pca(data1);
K1=data1*A;
[m1,n1]=size(K1);
for i=1:m1
    K1(i,n1+1)=1;
end
A=pca(data0);
K2=data0*A;
[m2,n2]=size(K2);
for i=1:m2
    K2(i,n2+1)=0;
end
split=round(m1*.6);
train=[K1(1:split,1:5);K2(1:split,1:5)];
test=[K1(split:m1,1:5);K2(split:m2,1:5)];
trainLabels=[K1(1:split,n1+1);K2(1:split,n2+1)];
testLabels=[K1(split:m1,n1+1);K2(split:m2,n2+1)];
[t1,s1]=size(testLabels);
[t2,s2]=size(testLabels);
tree=fitctree(train,trainLabels);
label=predict(tree,test);
count=0;
for i=1:t1
    if testLabels(i)==label(i)
        count=count+1;
    end
end
tn=0;
tp=0; 
for i=1:t1
    if testLabels(i)==0 && label(i)==0
        tn=tn+1; %tn
    end
    if testLabels(i)==1 && label(i)==1
        tp=tp+1; %tp
    end
end
tn
tp
neg=0; %n
pos=0; %p
for i=1:t1
    if testLabels(i)==0
        neg=neg+1;
    end
    if testLabels(i)==1
       pos=pos+1;
    end
end
neg
pos
falseP=neg-tn;
falseN=pos-tp;
N=neg+pos
accuracy=(tp+tn)/N
precision=tp/(tp+falseP)
recall=tp/pos
f_1=2*((precision*recall)/(precision+recall))
Mdl = fitcsvm(train,trainLabels)
label=predict(Mdl,test);
count=0;
for i=1:t1
    if testLabels(i)==label(i)
        count=count+1;
    end
end
tn=0;
tp=0; 
for i=1:t1
    if testLabels(i)==0 && label(i)==0
        tn=tn+1; %tn
    end
    if testLabels(i)==1 && label(i)==1
        tp=tp+1; %tp
    end
end
tn
tp
neg=0; %n
pos=0; %p
for i=1:t1
    if testLabels(i)==0
        neg=neg+1;
    end
    if testLabels(i)==1
       pos=pos+1;
    end
end
neg
pos
falseP=neg-tn;
falseN=pos-tp;
N=neg+pos
accuracy=(tp+tn)/N
precision=tp/(tp+falseP)
recall=tp/pos
f_1=2*((precision*recall)/(precision+recall))
toc

function r = dataforPCA1(M,N,O)
    starttime = round(M(:,1)*50/30,0);
    endtime = round(M(:,2)*50/30,0);
    [m, n]=size(N);
    [~, c]=size(O);
    [a, ~] = size(starttime);
    j = 1;
    d1=[];
    cc=[];
    for j=1:a
        d=[];
        for i=1:m        
            if i>=starttime(j) && i<=endtime(j)
                d=[d;N(i,2:n),O(i,2:c)];
                cc=[cc;i];
            end
        end
        mm=corrcoef(d);
        cor=[];
        for k=2:18
            for lol=1:k-1
                cor=[cor,mm(k,lol)];
            end
        end
        d1=[d1;reshape(cov(d),1,324),cor,mean(d),std(d),rms(d)];
    end
    r=d1;
end
function r = dataforPCA0(M,N,O)
    starttime = round(M(:,1)*50/30,0);
    endtime = round(M(:,2)*50/30,0);
    [m, n]=size(N);
    [~, c]=size(O);
    [a, ~] = size(starttime);
    j = 1;
    cc=[];
    d1=[];
    init=1;
    for j=1:a
        d=[];
        for i=init:m        
            if i>=starttime(j) && i<=endtime(j)
                init=endtime(j);
                break
            end
            d=[d;N(i,2:n),O(i,2:c)];
        end
        mm=corrcoef(d);
        cor=[];
        for k=2:18
            for lol=1:k-1
                cor=[cor,mm(k,lol)];
            end
        end
        d1=[d1;reshape(cov(d),1,324),cor,mean(d),std(d),rms(d)];
    end
    r=d1;
end