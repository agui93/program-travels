package intersection_of_two_linked_lists

/**
 * Given the heads of two singly linked-lists headA and headB, return the node at which the two lists intersect.
 * If the two linked lists have no intersection at all, return null.
 *
**/

type ListNode struct {
	Val  int
	Next *ListNode
}

func getIntersectionNode(headA, headB *ListNode) *ListNode {
	h1 := headA
	h2 := headB

	h1e := false
	h2e := false
	for !(h1e && h2e) {
		h1 = h1.Next
		h2 = h2.Next
		if h1 == nil {
			h1 = headB
			h1e = true
		}
		if h2 == nil {
			h2 = headA
			h2e = true
		}
	}

	for h1 != nil && h2 != nil {
		if h1 == h2 {
			return h1
		}
		h1 = h1.Next
		h2 = h2.Next
	}

	return nil
}
