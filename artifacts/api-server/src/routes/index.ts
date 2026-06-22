import { Router, type IRouter } from "express";
import healthRouter from "./health";
import authRouter from "./auth";
import usersRouter from "./users";
import newsRouter from "./news";
import embassiesRouter from "./embassies";
import tourismRouter from "./tourism";
import webinarsRouter from "./webinars";
import eventsRouter from "./events";
import postsRouter from "./posts";
import notificationsRouter from "./notifications";
import mdasRouter from "./mdas";
import opportunitiesRouter from "./opportunities";
import dashboardRouter from "./dashboard";
import registrationsRouter from "./registrations";
import contactMessagesRouter from "./contactMessages";

const router: IRouter = Router();

router.use(healthRouter);
router.use(authRouter);
router.use(usersRouter);
router.use(newsRouter);
router.use(embassiesRouter);
router.use(tourismRouter);
router.use(webinarsRouter);
router.use(eventsRouter);
router.use(postsRouter);
router.use(notificationsRouter);
router.use(mdasRouter);
router.use(opportunitiesRouter);
router.use(dashboardRouter);
router.use(registrationsRouter);
router.use(contactMessagesRouter);

export default router;
