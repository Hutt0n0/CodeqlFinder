import java
import semmle.code.java.dataflow.TaintTracking2
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.ExternalFlow

abstract class UploadFileSink extends DataFlow::Node { }
class DefaultUploadFileSink extends UploadFileSink{

    DefaultUploadFileSink(){
        sinkNode(this, "create-file") or sinkNode(this, "write-file")
    }


}
from DataFlow::PathNode sink
where   
    sink.getNode() instanceof UploadFileSink

select  sink.toString(),sink.getNode().getEnclosingCallable(), sink.getNode().getEnclosingCallable().getFile().getAbsolutePath(),"文件写入或者创建漏洞"

