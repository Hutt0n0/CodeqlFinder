/*
 * @Descripttion:
 * @version:
 * @Author: Hutt0n0
 * @Date: 2023-01-25 17:38:53
 * @LastEditTime: 2023-04-27 19:03:53
 */
package scan

import (
	"CodeqlFinder/codeql"
	"CodeqlFinder/utils"
	"fmt"
	"io/fs"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

/**
 * @author Hutt0n0
 * @func
 * @desc 读取.ql文件内容
 * @param {}
 * @return {}
 */
func readQlContent(path string) string {
	bcontent, err := ioutil.ReadFile(path)
	if err != nil {
		log.Println("读取ql文件失败")
		return ""
	}
	return string(bcontent)

}

/**
 * @author Hutt0n0
 * @func
 * @desc 运行.ql文件进行扫描主程序入口
 * @param {}
 * @return {}
 */
func RunJava(databaseql codeql.DatabaseCodeql) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	path := "plugins"
	var bqrsoutfile string
	tempProject := databaseql.Qlpath + "/" + "tempProject" //工作区
	bqrsoutfile = tempProject + "/" + "test.bqrs"
	resultpath := tempProject + "/" + "codeqlResult"
	b := utils.CheckFileExist(tempProject)
	if !b {
		err2 := os.Mkdir(tempProject, 0777)
		if err2 != nil {
			log.Println("工作区文件目录创建失败")
			return false
		}
	}
	tempB := utils.CheckFileExist(resultpath)
	if !tempB {
		err2 := os.Mkdir(resultpath, 0777)
		if err2 != nil {
			log.Println("结果存放目录创建失败")
			return false
		}
	}
	path = "plugins/lib"
	fidir, err := ioutil.ReadDir(path)
	if err != nil {
		log.Println("[x]读取lib文件失败")
	}
	for _, ent := range fidir {
		s := ent.Name()
		file := path + "/" + s
		Content := readQlContent(file)
		fmt.Println(Content)
		err2 := ioutil.WriteFile(tempProject+"/"+s, ([]byte)(Content), 0777)
		if err2 != nil {
			log.Println("[x]lib文件创建失败")
		}
	}
	i := strings.LastIndex(databaseql.Qlpath, ".ql")
	if i > 0 {
		//执行单文件
		qlcontent := readQlContent(databaseql.Qlpath)
		Scanresult := codeql.Query(databaseql, qlcontent, bqrsoutfile, tempProject)
		if Scanresult {
			newFileName := strings.Replace(databaseql.Qlpath, ".ql", ".csv", 1)
			csvFilePath := resultpath + "/" + newFileName
			analyzeResult := codeql.Analyze(csvFilePath, "csv", bqrsoutfile)
			if analyzeResult {
				b, err3 := ioutil.ReadFile(csvFilePath)
				if err3 != nil {
					log.Printf("%s文件读取失败", csvFilePath)
				}
				sresult := strings.Split(string(b), "\n")
				vulnum := len(sresult) - 2
				log.Printf("%s 发现 %d 个漏洞", databaseql.Qlpath, vulnum)
				if vulnum == 0 {
					err4 := os.Remove(csvFilePath)
					if err4 != nil {
						log.Printf("%s空文件删除失败", csvFilePath)
					}
				}
			}
		}
		return true
	} else {
		//执行目录下的文件
		//读取plugins目录下面的ql文件
		var dirs []fs.FileInfo
		var err error
		if databaseql.Static {
			dirs, err = ioutil.ReadDir("plugins/StaticAnalize")
			path = "plugins/StaticAnalize"
			if err != nil {
				log.Println("读取plugins目录下文件失败")
				return false
			}
		} else {
			dirs, err = ioutil.ReadDir("plugins/SourceToSink")
			path = "plugins/SourceToSink"
			if err != nil {
				log.Println("读取plugins目录下文件失败")
				return false
			}
		}

		num := 0
		for _, entry := range dirs {
			direname := entry.Name()
			qlJavaPath := path + "/" + direname
			javaDir, err2 := ioutil.ReadDir(qlJavaPath)
			if err2 != nil {
				log.Printf("读取plugins下的%s失败", direname)
				return false
			}
			for _, entry2 := range javaDir {
				dirFileName := entry2.Name()
				qlscriptPath := qlJavaPath + "/" + dirFileName

				log.Println("scaning: " + qlscriptPath)
				qlcontent := readQlContent(qlscriptPath)
				// i := strings.LastIndex(dirFileName, ".")
				// if dirFileName[i:] == ".qll" {
				// 	ioutil.WriteFile(tempProject+"/"+dirFileName, []byte(qlcontent), 0666)
				// 	continue
				// }
				Scanresult := codeql.Query(databaseql, qlcontent, bqrsoutfile, tempProject)
				if Scanresult {
					num++
					log.Printf("Finish：%s 完成%d个脚本", dirFileName, num)
					//完成扫描后，需要对结果进行解析，输出保存。
					newFileName := strings.Replace(dirFileName, ".ql", ".csv", 1)
					csvFilePath := resultpath + "/" + newFileName
					analyzeResult := codeql.Analyze(csvFilePath, "csv", bqrsoutfile)
					if analyzeResult {
						b, err3 := ioutil.ReadFile(csvFilePath)
						if err3 != nil {
							log.Printf("%s文件读取失败", csvFilePath)
						}
						sresult := strings.Split(string(b), "\n")
						vulnum := len(sresult) - 2
						log.Printf("%s 发现 %d 个漏洞", qlscriptPath, len(sresult)-2)
						if vulnum == 0 {
							err4 := os.Remove(csvFilePath)
							if err4 != nil {
								log.Printf("%s空文件删除失败", csvFilePath)
							}
						}
					}
				}
			}

		}
	}

	return true

}
