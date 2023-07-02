package linked_list_cycle_ii

type ListNode struct {
	Val  int
	Next *ListNode
}

func detectCycle(head *ListNode) *ListNode {
	p1 := head
	p2 := head
	meet := false
	for p2 != nil && p2.Next != nil {
		p2 = p2.Next.Next
		p1 = p1.Next
		if p1 == p2 {
			meet = true
			break
		}
	}

	if meet {
		p2 = head
		for p1 != p2 {
			p1 = p1.Next
			p2 = p2.Next
		}
		return p1
	}

	return nil
}
