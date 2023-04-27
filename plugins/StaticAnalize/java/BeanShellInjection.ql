/**
 * @name bsh命令执行
 * @kind path-problem
 * 
 */
import java
import semmle.code.java.dataflow.FlowSources
import DataFlow::PathGraph


/** A call to `Interpreter.eval`. */
class InterpreterEvalCall extends MethodAccess {
  InterpreterEvalCall() {
    this.getMethod().hasName("eval") and
    this.getMethod().getDeclaringType().hasQualifiedName("bsh", "Interpreter")
  }
}

/** A call to `BshScriptEvaluator.evaluate`. */
class BshScriptEvaluatorEvaluateCall extends MethodAccess {
  BshScriptEvaluatorEvaluateCall() {
    this.getMethod().hasName("evaluate") and
    this.getMethod()
        .getDeclaringType()
        .hasQualifiedName("org.springframework.scripting.bsh", "BshScriptEvaluator")
  }
}

/** A sink for BeanShell expression injection vulnerabilities. */
class BeanShellInjectionSink extends DataFlow::Node {
  BeanShellInjectionSink() {
    this.asExpr() = any(InterpreterEvalCall iec).getArgument(0) or
    this.asExpr() = any(BshScriptEvaluatorEvaluateCall bseec).getArgument(0)
  }
}




from  DataFlow::PathNode sink
where sink.getNode() instanceof BeanShellInjectionSink
select  sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(), "BeanShell injection"
