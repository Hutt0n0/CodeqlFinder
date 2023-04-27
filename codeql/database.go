/*
 * @Descripttion:
 * @version:
 * @Author: Hutt0n0
 * @Date: 2023-01-25 17:28:51
 * @LastEditTime: 2023-04-27 19:15:01
 */
package codeql

import (
	"CodeqlFinder/utils"
	"io/ioutil"
	"log"
	"strings"

	"github.com/google/uuid"
)

type DatabaseCodeql struct {
	Database   string //数据库位置
	Qlpath     string //ql脚本位置
	Sourcecode string //源码位置
	Cmd        string // 编译命令
	Static     bool   //指定是静态分析还是污点分析
}

/**
 * @author Hutt0n0
 * @func
 * @desc 执行.ql文件进行扫描
 * @param {}
 * @return {}
 */
func Query(databaseql DatabaseCodeql, qlContent string, outfile string, temp string) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	uuid1 := uuid.New()
	s := uuid1.String()
	queryPath := temp + "/" + s + ".ql"
	err := ioutil.WriteFile(queryPath, []byte(qlContent), 0666)
	if err != nil {
		log.Fatalln("写入临时ql文件失败")
		return false
	}
	dmo := "query run -d " + databaseql.Database + " " + "-o " + outfile + " " + queryPath
	s2 := strings.Split(dmo, " ")
	cmd := utils.ExecCmd(s2)
	b, err2 := cmd.CombinedOutput()
	if err2 != nil {
		log.Fatalf("codeql query failed : %s", string(b))
		return false
	}
	return true
}

/**
 * @author Hutt0n0
 * @func
 * @desc 执行结果分析程序
 * @param {}
 * @return {}
 */
func Analyze(output string, format string, bqrspath string) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	var params []string
	params = append(append(append(append(append(append(append(params, "bqrs"), "decode"), "--format"), format), "-o"), output), bqrspath)
	cmd := utils.ExecCmd(params)
	byteoutput, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatalf("结果解析错误:%s", string(byteoutput))
		return false
	}
	return true
}

func AnalyzeInstead(databaseql DatabaseCodeql, qlContent string, outfile string) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	uuid1 := uuid.New()
	s := uuid1.String()
	queryPath := databaseql.Qlpath + "/" + s + ".ql"
	err := ioutil.WriteFile(queryPath, []byte(qlContent), 0666)
	if err != nil {
		log.Fatalln("写入临时ql文件失败")
		return false
	}
	var params []string
	params = append(append(append(append(append(append(append(append(params, "database"), "analyze"), "--format"), "csv"), "--output"), outfile), databaseql.Database), queryPath)
	utils.ReadTimeExecCmd(params)
	return true
}

/**
 * @author Hutt0n0
 * @func
 * @desc 将源码编译成数据库
 * @param {}
 * @return {}
 */
func CreateDB(databaseql DatabaseCodeql) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	var params []string
	params = append(append(append(append(append(append(append(append(append(append(append(params, "database"), "create"), databaseql.Database), "--language"), "java"), "--command"), databaseql.Cmd), "--source-root"), databaseql.Sourcecode), "--overwrite"))
	b := utils.ReadTimeExecCmd(params)
	if !b {
		log.Fatalf("源码编译成数据库报错")
		return false
	}
	return true
}
