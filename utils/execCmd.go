package utils

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"sync"
)

/**
 * @author Hutt0n0
 * @func
 * @desc 同一命令执行入口
 * @param {}
 * @return {}
 */
func ExecCmd(options []string) *exec.Cmd {
	sysType := runtime.GOOS
	var cmd *exec.Cmd
	if strings.Contains(strings.ToLower(sysType), "linux") || strings.Contains(strings.ToLower(sysType), "darwin") {
		cmd = exec.Command("codeql", options...)
	} else {
		cmd = exec.Command("codeql.exe", options...)
	}
	return cmd
}

func ReadTimeExecCmd(options []string) bool {
	//获取执行命令
	sysType := runtime.GOOS
	var cmd *exec.Cmd
	if strings.Contains(strings.ToLower(sysType), "linux") || strings.Contains(strings.ToLower(sysType), "darwin") {
		cmd = exec.Command("codeql", options...)
	} else {
		cmd = exec.Command("codeql.exe", options...)
	}
	cmd.Stdin = os.Stdin

	var wg sync.WaitGroup
	wg.Add(2)
	//捕获标准输出
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Println("ERROR:", err)
		return false
	}
	readout := bufio.NewReader(stdout)
	go func() {
		defer wg.Done()
		getOutput(readout)
	}()

	//捕获标准错误
	stderr, err := cmd.StderrPipe()
	if err != nil {
		fmt.Println("ERROR:", err)
		os.Exit(1)
	}
	readerr := bufio.NewReader(stderr)
	go func() {
		defer wg.Done()
		getOutput(readerr)
	}()

	//执行命令
	cmd.Run()
	wg.Wait()
	return true
}

func getOutput(reader *bufio.Reader) {
	var sumOutput string //统计屏幕的全部输出内容
	outputBytes := make([]byte, 200)
	for {
		n, err := reader.Read(outputBytes) //获取屏幕的实时输出(并不是按照回车分割，所以要结合sumOutput)
		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Println(err)
			sumOutput += err.Error()
		}
		output := string(outputBytes[:n])
		fmt.Print(output) //输出屏幕内容
		sumOutput += output
	}
	return
}
