package remove_nth_node_from_end_of_list

/**
 *  Remove Nth Node From End of List
 *  Given the head of a linked list, remove the nth node from the end of the list and return its head.
 *
 *  思路: 两个间隔n的指针同时移动,
 *  	 考虑边界条件: n == 1 ,n==len(head)的情况
 *		 最终删除的是: 第一个指针的Next节点
 */

type ListNode struct {
	Val  int
	Next *ListNode
}

func removeNthFromEnd(head *ListNode, n int) *ListNode {
	if head == nil {
		return nil
	}

	h2 := head
	for i := 0; i < n-1; i++ {
		if h2 == nil {
			return nil
		}
		h2 = h2.Next
	}

	var h1 *ListNode = nil
	for h2.Next != nil {
		if h1 == nil {
			h1 = head
		} else {
			h1 = h1.Next
		}
		h2 = h2.Next
	}

	if h1 == nil {
		return head.Next
	} else {
		h1.Next = h1.Next.Next
	}

	return head
}
