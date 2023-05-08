/*
 * @Descripttion:
 * @version:
 * @Author: Hutt0n0
 * @Date: 2023-01-25 14:52:46
 * @LastEditTime: 2023-05-08 14:07:40
 */
package main

import (
	"CodeqlFinder/codeql"
	"CodeqlFinder/scan"
	"CodeqlFinder/utils"
	"flag"
	"fmt"
	"log"
)

/**
 * @author Hutt0n0
 * @func
 * @desc CodeqlFinder主入口
 * @param {}
 * @return {}
 */
func main() {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	var database string
	var sourceCode string
	var skipEnv bool
	var compile bool
	var qlpath string
	var cmd string
	var static bool

	flag.StringVar(&database, "d", "", "编译后的数据库文件目录，默认为空")
	flag.StringVar(&sourceCode, "s", "", "源码位置，默认为空")
	flag.BoolVar(&skipEnv, "skip", false, "是否跳过环境监察，跳过加上-skip true，默认是不跳过")
	flag.StringVar(&qlpath, "q", "", "指定ql目录路径或者指定单个ql脚本，默认为空")
	flag.StringVar(&cmd, "cmd", "mvn clean package -DskipTests=true", "maven编译命令，默认是mvn clean package -DskipTests=true")
	flag.BoolVar(&static, "static", false, "若只寻找sink点，需要加上-static true。默认为污点利用链分析")
	flag.Parse()
	lengthArgs := len(flag.Args())
	if lengthArgs <= 0 {
		f := flag.Usage
		f()
		fmt.Println("第一次执行推荐检查环境：./CodeqlFinder -d 数据库文件目录 -q ql文件目录路径 -static true")
		fmt.Println("直接运行：./CodeqlFinder -d 数据库文件目录 -q ql文件目录路径 -static true -skip true")
		fmt.Println("编译源码：./CodeqlFinder -d 存放数据库文件目录 -s 要编译的源码位置  -skip true -cmd maven编译命令[可选] ")
		return
	}
	compile = false
	database = utils.RemoveLastSlash(database)
	qlpath = utils.RemoveLastSlash(qlpath)
	sourceCode = utils.RemoveLastSlash(sourceCode)
	if sourceCode != "" {
		compile = true
	}
	if !skipEnv {
		checkCodeqlEnv := utils.CheckCodeqlEnv()
		checkdatabase := utils.CheckDatabase(database)
		checkMvn := utils.CheckMaven()
		CheckQLPATH := utils.CheckQLPATH(database, qlpath)
		if !checkCodeqlEnv || !checkdatabase || !checkMvn || !CheckQLPATH {
			log.Println("[x]环境检查存在问题")
			return
		}
		log.Println("[*]环境正常")
	}
	var databaseql codeql.DatabaseCodeql
	databaseql.Sourcecode = sourceCode
	databaseql.Database = database
	databaseql.Qlpath = qlpath
	databaseql.Cmd = cmd
	databaseql.Static = static
	//直接对已经编译好的数据库进行扫描
	if database != "" && !compile {
		b := scan.RunJava(databaseql)
		if b {
			log.Printf("[*]success 已经完成对%s数据库的扫描", database)
		}
	}
	//编译源码
	if compile && sourceCode != "" && database != "" {
		b := utils.CheckSourceCode(sourceCode)
		if !b {
			log.Printf("[x]环境检查失败%s", sourceCode)
			return
		}
		b2 := codeql.CreateDB(databaseql)
		if !b2 {
			log.Printf("[x]%s 源码编译阶段失败", sourceCode)
			return
		}
		log.Printf("[*]success 完成对%s 源码编译", sourceCode)
	}

}
