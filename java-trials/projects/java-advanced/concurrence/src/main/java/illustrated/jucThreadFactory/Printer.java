package illustrated.jucThreadFactory;

public class Printer implements Runnable {

    private final String message;

    public Printer(String message) {
        this.message = message;
    }

    public void run() {
        for (int i = 0; i < 1000; i++) {
            System.out.print(message);
        }
    }
}
