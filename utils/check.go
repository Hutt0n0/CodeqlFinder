package utils

import (
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/google/uuid"
)

/**
 * @author Hutt0n0
 * @func
 * @desc 检查数据库文件是否合法
 * @param {}
 * @return {}
 */

func CheckDatabase(database string) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	database = database + "/"
	b := CheckFileExist(database)
	if !b {
		log.Println("数据库文件不存在")
		return false
	}
	dbfile := database + "codeql-database.yml"
	dbzip := database + "src.zip"
	if !CheckFileExist(dbfile) || !CheckFileExist(dbzip) {
		log.Println("codeql-database.yml、src.zip其中一个文件不存在.")
		return false
	}
	return true
}

/**
 * @author Hutt0n0
 * @func
 * @desc 检查codeql环境是否合法
 * @param {}
 * @return {}
 */
func CheckCodeqlEnv() bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	var cmd *exec.Cmd
	var params []string
	params = append(params, "--version")
	cmd = ExecCmd(params)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Printf("codeql combined err out:\n%s\n", string(out))
		return false
	}
	if !strings.Contains(string(out), "release") {
		log.Println("codeql is not install or the codeql path is not in env path  ")
		return false
	}

	return true

}

/**
 * @author Hutt0n0
 * @func
 * @desc 检查maven环境是否合法
 * @param {}
 * @return {}
 */
func CheckMaven() bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	var cmd *exec.Cmd
	var params []string
	params = append(params, "--version")
	cmd = exec.Command("mvn", params...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Printf("mvn combined err out:\n%s\n", string(out))
		return false
	}
	if !strings.Contains(string(out), "Apache Maven") {
		log.Println("Maven is not install or the Maven is not in env path")
		return false
	}
	return true
}

/**
 * @author Hutt0n0
 * @func
 * @desc 检查ql路径是否存在以及合法
 * @param {}
 * @return {}
 */
func CheckQLPATH(database string, qlpath string) bool {
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	uuid1 := uuid.New()
	key := uuid1.String()
	b2 := CheckFileExist(qlpath)
	if !b2 {
		log.Println("qlpath is not exist ")
		return false
	}
	helloTest := "import java\n\n select \"CheckISnormal\""
	qlfile := qlpath + "/" + key + ".ql"
	err2 := ioutil.WriteFile(qlfile, []byte(helloTest), 0777)
	if err2 != nil {
		log.Println("create temp ql failed!! ")
		return false
	}
	var cmd *exec.Cmd
	var param []string
	param = append(append(append(append(append(param, "query"), "run"), "-d"), database), qlfile)
	cmd = ExecCmd(param)
	b, err3 := cmd.CombinedOutput()
	if err3 != nil {
		log.Println("'codeql query run -d ' failed ")
		return false
	}
	if strings.Contains(string(b), "CheckISnormal") {
		os.Remove(qlfile)
		return true
	} else {
		return false
	}
}

/**
 * @author Hutt0n0
 * @func
 * @desc 判断要编译的源代码目录是否存在和合法
 * @param {}
 * @return {}
 */
func CheckSourceCode(sourcepath string) bool {
	b := CheckFileExist(sourcepath)
	pompath := sourcepath + "/" + "pom.xml"
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	if !b {
		log.Default().Printf("指定的源代码位置%s不存在", sourcepath)
		return false
	}
	b2 := CheckFileExist(pompath)
	if !b2 {
		log.Default().Printf("指定的源代码的pom.xml%s不存在", pompath)
		return false
	}

	return true
}
