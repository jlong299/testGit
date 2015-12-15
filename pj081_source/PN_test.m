% PN gen
close all;
clear all;
tic;

% %% serial for PN15 [15,1,0]
% pn = ones(1,15);
% N = 2^15-1;
% M = 2*N;
% for i=1:M
% 	outpn(1,i) = pn(15);
% 	pn15 = pn(15);
% 	pn14 = pn(14);
% 	pn(15:-1:2) = pn(14:-1:1);
% 	pn(1) = xor(pn15, pn14);
% end

% % verify the period of PN seq 
% equRcrd = 1;
% for k = 1:N
% 	if outpn(k) ~= outpn(k+N) 
% 		equRcrd = 0;
% 	end
% end
% equRcrd

% % Traversal
% % only for 1:100, due to the long running time
% % you can change the traversal range 
% for i=1:10 %N-15
% 	cnt(i)=0;
% 	for k=(i+1):N-14
% 		if outpn(i:i+14) == outpn(k:k+14)
% 			cnt(i) = cnt(i)+1;
% 		end
% 	end
% end
% max(cnt)

%% serial for PN17 [17,3,0]
pn = ones(1,17);
N = 2^17-1;
M = 2*N;
for i=1:M
	outpn(1,i) = pn(17);
	pn17 = pn(17);
	pn14 = pn(14);
	pn(17:-1:2) = pn(16:-1:1);
	pn(1) = xor(pn17, pn14);
end

% verify the period of PN seq 
equRcrd = 1;
for k = 1:N
	if outpn(k) ~= outpn(k+N) 
		equRcrd = 0;
	end
end
equRcrd

% Traversal
% only for 1:100, due to the long running time
% you can change the traversal range 
ofst = 1000;
for i=(1+ofst):(10+ofst) %N-17
	cnt(i)=0;
	for k=(i+1):N-16
		if outpn(i:i+16) == outpn(k:k+16)
			cnt(i) = cnt(i)+1;
		end
	end
end
max(cnt)

% for k=1:N-16
% 		if outpn(k:k+16) == [0 1 0 1 1 0 0 0 1 1 1 1 0 0 1 1 0]
% 			break;
% 		end
% end
% outpn(k:k+31)

%% 8 parallel branches for PN17 [17, 3, 0]
% 17-3+8+1 >= 1 
% output :  outpn_p8 is little endian !
pn_p8 = ones(1,17);
N_p8 = 2^17/8;
for i=1:N_p8
	outpn_p8(:,i) = pn_p8(17:-1:10);
	pn_p8_copy = pn_p8;
	pn_p8(17:-1:9) = pn_p8(9:-1:1);
	pn_p8(8:-1:1) = xor(pn_p8_copy(17:-1:10),pn_p8_copy(14:-1:7));
end

toc
