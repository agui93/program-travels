package remove_nth_node_from_end_of_list

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test_removeNthFromEnd(t *testing.T) {
	h := nodes([]int{1, 2, 3, 4, 5})
	h = removeNthFromEnd(h, 2)
	assert.True(t, cmp(h, []int{1, 2, 3, 5}))
}

func nodes(nums []int) *ListNode {

	h := &ListNode{
		Val:  nums[0],
		Next: nil,
	}

	t := h
	for _, num := range nums[1:] {
		t.Next = &ListNode{
			Val:  num,
			Next: nil,
		}
		t = t.Next
	}

	return h
}

func cmp(h *ListNode, nums []int) bool {
	for _, num := range nums {
		if h == nil || num != h.Val {
			return false
		}
		h = h.Next
	}

	return true
}
