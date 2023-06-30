public with sharing class UtilityClass {
    public static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }

    public static String formatInteger(Decimal increment){
        String zerosToAdd;
        String strIncrement = String.valueOf(increment);
        Integer zerosNumberToAdd = 4 - strIncrement.length();
        if(zerosNumberToAdd > 0){
            zerosToAdd = '0'.repeat(zerosNumberToAdd);
        }
        return zerosToAdd + strIncrement;
    }
}