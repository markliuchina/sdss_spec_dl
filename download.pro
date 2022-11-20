;;下载程序的形式
Pro download, mjd = mjd, plate = plate, fiberid = fiberid, bad = bad, st0 = st0, st1 = st1

;;程序目的：基于plate-mjd-fiberid信息完成SDSS光谱数据的抓取

;;参数解释：
;;输入参数：
;;mjd：光谱数据对应的mjd信息
;;plate：光谱数据对应的plate信息
;;fiberid：光谱数据对应的fiberid信息
;;st0：光谱数据下载时的开始序号
;;st1：光谱数据下载时的终止序号

;;输出参数：
;;bad：存储文件，输出未完成下载的光谱数据的plate-mjd-fiberid信息

;;判断输入的plate-mjd-fiberid信息是否匹配

IF N_elements(mjd) ne N_elements(plate) or N_elements(mjd) ne N_elements(fiberid) or N_elements(fiberid) ne N_elements(plate) THEN BEGIN
    print, '=================================='
    print, '==NJNU==ASTROPHYSICS=MINGFENGLIU=='
    print, '=================================='
    print, 'MJD, PLATE, FIBERID, NOT MATCHED!!'
    print, '=================================='
    print, '==NJNU==ASTROPHYSICS=MINGFENGLIU=='
    print, '=================================='
    stop
END

;;准备plate-mjd-fiberid信息
;;mjd：5个字符
;;plate：4个字符
;;fiberid：4个字符
;;输入的plate-mjd-fiberid可以是字符型，也可以是数字型
;;将输入的plate-mjd-fiberid转换成字符型

mjd = strcompress(string(mjd),/remove_all)
pl = strcompress(string(plate),/remove_all)
fib = strcompress(string(fiberid),/remove_all)

;;SDSS下载地址准备
;;包括SDSS和eBOSS两个

ss0 = 'https://data.sdss.org/sas/dr16/sdss/spectro/redux/26/spectra/'
ss3 = 'https://data.sdss.org/sas/dr16/eboss/spectro/redux/v5_13_0/spectra/'

;;光谱数据下载序号准备
;;st0=0：从第0个光谱数据开始下载

IF N_elements(st0) eq 0 THEN BEGIN
    st0 = 0L
END
IF N_elements(st1) eq 0 THEN BEGIN
    st1 = N_elements(mjd) - 1L
END

;;如果有光谱数据未能正常下载，写入该bad文件中

openw, lun, 'Bad_download_' + strcompress(string(fix(st0)), /remove_all) + '_' + strcompress(string(fix(st1)), /remove_all) + '_list', /get_lun

;;开始光谱的下载

FOR i = st0, st1 DO BEGIN

    ;;将输入plate-mjd-fiberid转换成符合要求的字符串

    IF double(pl[i]) ge 1000 and double(pl[i]) lt 10000 THEN BEGIN
        pl[i] = pl[i]
    END
    IF double(pl[i]) ge 100 and double(pl[i]) lt 100 THEN BEGIN
        pl[i] = '0' + pl[i]
    END
    IF double(pl[i]) ge 10 and double(pl[i]) lt 100 THEN BEGIN
        pl[i] = '00' + pl[i]
    END
    IF double(fib[i]) lt 10 THEN BEGIN
        fib[i] = fib[i]
    END
    IF double(fib[i]) ge 10 and double(fib[i]) lt 100 THEN BEGIN
        fib[i] = fib[i]
    END
    IF double(fib[i]) ge 100 and double(fib[i]) lt 1000 THEN BEGIN
        fib[i] = fib[i]
    END
    
    ;;光谱数据的名称

    file = 'spec-' + pl[i] + '-' + mjd[i] + '-' + fib[i] + '.fits'

    ;;光谱数据对应的SDSS下载地址

    sp0 = ss0 + pl[i] + '/' + file ;SDSS的地址
    sp3 = ss3 + pl[i] + '/' + file ;eBOSS的地址

    ;;使用Linux指令wget进行光谱数据的下载
    ;;(一定要注意wget -c与地址之间一定要有一个空格！)
    ;;如果有SDSS的数据可供下载，那么就执行
   
    IF not file_test(file) THEN BEGIN
        spawn, 'wget -c' + ' ' + sp0
    END

    ;;如果没有SDSS的数据，但有eBOSS的数据可供下载，那么就执行

    IF not file_test(file) THEN BEGIN
        spawn, 'wget -c' + ' ' + sp3
    END

    ;;两个数据都没有，那么就执行bad文件的写入，这里加入的文件名与下载地址的信息，便于下载失败检查

    IF not file_test(file) THEN BEGIN
        printf, lun, 'filename = ' + file, format = '(1(A0, 2X))'
        printf, lun, 'SDSS url = ' + sp0, format = '(1(A0, 2X))'
        printf, lun, 'eBOSS url = ' + sp3, format = '(1(A0, 2X))'
    END
END

free_lun, lun

END