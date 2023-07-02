package middle_of_the_linked_list

type ListNode struct {
	Val  int
	Next *ListNode
}

func middleNode(head *ListNode) *ListNode {
	if head == nil {
		return nil
	}
	p1 := head
	p2 := head

	for p2 != nil && p2.Next != nil {
		p2 = p2.Next.Next
		p1 = p1.Next
	}

	return p1
}
