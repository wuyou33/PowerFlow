function print_title(PRINT_LENGTH,type,str,value)
%% 符号说明type
% 1:  ━     连续      框线      粗实线
% 2:  ═     连续      框线      双线
% 3:  ─     连续      框线      单线
% 4:  =     断续      框线      等号
% 5:  -     断续      框线      减号
% 6： .     断续      引线      点线

switch type
    case 1
        unit = '━';
    case 2
        unit = '═';
    case 3
        unit = '─';
    case 4
        unit = '=';
    case 5
        unit = '-';
    case 6 % 单线索引方式
        unit = '.';
        if nargin > 3 
            fprintf([char(unit * ones(1, PRINT_LENGTH)), ' ',str, '\n'],value);  % 有变量输入
        else
            fprintf([char(unit * ones(1, PRINT_LENGTH)), ' ', str, '\n']);
        end
        return;
    otherwise
        unit = '-';  % 默认方式 “ 减号 ”
end

if type >= 6 || unit == '.'
    if type == 6
        error('print_title: 程序逻辑错误，请调试');
    end
    error('print_title: 输出函数错误，type参数请输入小于7的正整数');
end
%% 计算输出字符的长度，用于居中
en = 0;  % 英文的个数
num = 0; % 数字的个数
 for i = 1:length(str)  
	 p = double(str(i)); 
     if p<128 
		en = en+1;  %% 非汉字个数
     end
     if str(i) == '%'
         num = num + 1;  % 数字的个数（输出）
     end
 end 
 cn = length(str)-en;  % 汉字个数
 sum = length(str) - num + cn;   % 输出的字节长度
%% 调整边框形式
 if unit=='-'||unit=='─'  % 调整边框
    line1 = ['┌',char(unit * ones(1, PRINT_LENGTH)),'┐'];
    line2 = ['└',char(unit * ones(1, PRINT_LENGTH)),'┘'];
 elseif unit == '═' || unit == '='
    line1 = ['╔',char(unit * ones(1, PRINT_LENGTH)),'╗'];
    line2 = ['╚',char(unit * ones(1, PRINT_LENGTH)),'╝'];
 else
    line1 = ['┍',char(unit * ones(1, PRINT_LENGTH)),'┑'];
    line2 = ['┕',char(unit * ones(1, PRINT_LENGTH)),'┙'];
 end
%% 形成内容框
line_length = length( line1 );
blanket = char( ' ' * ones(1, floor((line_length-sum)/2) ) );
fprintf(['\n',line1,'\n']);
if nargin > 3 
    fprintf([blanket,str,blanket,'\n'],value); % 有变量输入
else
    fprintf([blanket,str,blanket,'\n']);
end
fprintf([line2,'\n']);
