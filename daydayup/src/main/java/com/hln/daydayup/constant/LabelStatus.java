package com.hln.daydayup.constant;

public enum LabelStatus {

    ESSCERYANDURGENT (0),//重要紧急
    NESSCERYNOTURGENT(1),//重要不紧急
    NOTNESSCERYBUTURGENT(3),//不重要紧急
    NOTNESSCERYNOTURGENT(4);//不重要不紧急

    private final Integer label;

    LabelStatus(Integer label) {
        this.label = label;
    }

    @Override
    public String toString() {
        return label.toString();
    }
}
