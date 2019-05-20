public class Fibonacci{
    // 递归实现求第Index 个数的大小
    public int RecUrive(int index)
    {
        if (index< 3)
        {
            return 1;
        }else{
            return RecUrive(index - 1) + RecUrive(index - 2);
        }
    }
}