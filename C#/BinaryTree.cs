using System;

// 定义一个二叉树
// 采用范型，适应性更广
public class Tree<TItem> where TItem:IComparable<TItem>
{
    private TItem NodeData;
    private Tree<TItem> Left;

    private Tree<TItem> Right;

    public Tree(TItem nodeValue){
        this.NodeData = nodeValue;
        this.Right = null;
        this.Left = null;
    }

    // 插入操作
    public void Insert(TItem newItem){
        TItem currentnodeValue = this.NodeData;
        if (currentnodeValue.CompareTo(newItem) >= 0){
            if(this.Left == null){
                this.Left = new Tree<TItem>(newItem);
            }else{
                this.Left.Insert(newItem);
            }
        }else{
            if (this.Right == null){
                this.Right = new Tree<TItem>(newItem);
            }else{
                this.Right.Insert(newItem);
            }
        }
    }

    // 中序遍历
    public void TraverseTreeInOrder(){
        if(this.Left!=null){
            this.Left.TraverseTreeInOrder();
        }
        // 当前没有左子树，打印当前根节点
        Console.WriteLine(this.NodeData);
        if(this.Right!=null){
            this.Right.TraverseTreeInOrder();
        }
    }

    // 二叉树查找
    public Boolean TreeQuery(Tree<TItem> tree, TItem item){
        if(tree == null){
            return false;
        }
        if(this.NodeData.CompareTo(item)> 0)
        {
            return TreeQuery(tree.Left, item);
        }else if(this.NodeData.CompareTo(item)< 0)
        {
            return TreeQuery(tree.Right, item);
        }else
        {
            return true;
        }
    }

    //查找二叉树最大值：原理：一直访问至无右子树的节点，并返回此时的节点
    public TItem TreeQueryMax(Tree<TItem> tree){
        if (tree != null){
            while(tree!=null&&tree.Right!=null)
            {
                tree = tree.Right;
            }
            return tree.NodeData;
        }
        return default(TItem);
    }

    //二叉树节点的删除：最复杂情况是删除节点同时有左子树和右子树时，从右子树找出最小节点，替换当前被删节点


}

class Program{
    static void Main(string[] args){
        Tree<int> t = new Tree<int>(8);
        int[] a = {3,10,1,6,4,14,13};
        foreach(int item in a){
            t.Insert(item);
        }

        Console.WriteLine("二叉树打印");
        t.TraverseTreeInOrder();
        //删除没写
        Console.Read();
    }
}