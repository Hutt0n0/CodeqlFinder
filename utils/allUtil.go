package utils

import (
	"os"
	"strings"
)

/**
 * @author Hutt0n0
 * @func
 * @desc 移除字符串最后的'/'
 * @param {}
 * @return {}
 */
func RemoveLastSlash(path string) string {
	i := strings.LastIndex(path, "/")

	if len(path) <= 0 || i < 0 {
		return path
	}

	length := len(path)
	if i < length-1 {
		return path
	}
	return path[0 : length-1]
}

/**
 * @author Hutt0n0
 * @func
 * @desc 检查文件或目录是否存在，如果存在返回true,否则返回false
 * @param {}
 * @return {}
 */
func CheckFileExist(path string) bool {
	_, err := os.Stat(path)
	b := os.IsNotExist(err)
	if !b {
		return true
	}
	return false
}







