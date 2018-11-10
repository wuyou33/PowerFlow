function print_title(PRINT_LENGTH,type,str,value)
%% ����˵��type
% 1:  ��     ����      ����      ��ʵ��
% 2:  �T     ����      ����      ˫��
% 3:  ��     ����      ����      ����
% 4:  =     ����      ����      �Ⱥ�
% 5:  -     ����      ����      ����
% 6�� .     ����      ����      ����

switch type
    case 1
        unit = '��';
    case 2
        unit = '�T';
    case 3
        unit = '��';
    case 4
        unit = '=';
    case 5
        unit = '-';
    case 6 % ����������ʽ
        unit = '.';
        if nargin > 3 
            fprintf([char(unit * ones(1, PRINT_LENGTH)), ' ',str, '\n'],value);  % �б�������
        else
            fprintf([char(unit * ones(1, PRINT_LENGTH)), ' ', str, '\n']);
        end
        return;
    otherwise
        unit = '-';  % Ĭ�Ϸ�ʽ �� ���� ��
end

if type >= 6 || unit == '.'
    if type == 6
        error('print_title: �����߼����������');
    end
    error('print_title: �����������type����������С��7��������');
end
%% ��������ַ��ĳ��ȣ����ھ���
en = 0;  % Ӣ�ĵĸ���
num = 0; % ���ֵĸ���
 for i = 1:length(str)  
	 p = double(str(i)); 
     if p<128 
		en = en+1;  %% �Ǻ��ָ���
     end
     if str(i) == '%'
         num = num + 1;  % ���ֵĸ����������
     end
 end 
 cn = length(str)-en;  % ���ָ���
 sum = length(str) - num + cn;   % ������ֽڳ���
%% �����߿���ʽ
 if unit=='-'||unit=='��'  % �����߿�
    line1 = ['��',char(unit * ones(1, PRINT_LENGTH)),'��'];
    line2 = ['��',char(unit * ones(1, PRINT_LENGTH)),'��'];
 elseif unit == '�T' || unit == '='
    line1 = ['�X',char(unit * ones(1, PRINT_LENGTH)),'�['];
    line2 = ['�^',char(unit * ones(1, PRINT_LENGTH)),'�a'];
 else
    line1 = ['��',char(unit * ones(1, PRINT_LENGTH)),'��'];
    line2 = ['��',char(unit * ones(1, PRINT_LENGTH)),'��'];
 end
%% �γ����ݿ�
line_length = length( line1 );
blanket = char( ' ' * ones(1, floor((line_length-sum)/2) ) );
fprintf(['\n',line1,'\n']);
if nargin > 3 
    fprintf([blanket,str,blanket,'\n'],value); % �б�������
else
    fprintf([blanket,str,blanket,'\n']);
end
fprintf([line2,'\n']);