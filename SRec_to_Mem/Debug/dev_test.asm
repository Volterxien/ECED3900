	org #1000
movl $20,R1
movl $2,R2
movl $0,R3
movl $16,R4
movl #10,R5

st.b R4,R3
st.b R1,R2
movl $3,R1
st.b R5,R1 

movl #1c,R4

st.b R4,R3

st.b R4,R1
st.b R4,R1

ld.b R3,R1
ld.b R2,R1
